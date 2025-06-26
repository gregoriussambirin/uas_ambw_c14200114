import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uas_c14200114/models/recipe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  Future<void> _addRecipe() async {
    if (_recipeNameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _ingredientsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields must be filled!')),
      );
      return;
    }

    final User? currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add a recipe.')),
      );
      return;
    }

    try {
      // Save recipe to Supabase
      await supabase.from('recipes').insert({
        'user_id': currentUser.id, // Store based on user's UID
        'name': _recipeNameController.text,
        'description': _descriptionController.text,
        'ingredients': _ingredientsController.text.split('\n'), // Store ingredients as a list
      });

      // Clear controllers after saving
      _recipeNameController.clear();
      _descriptionController.clear();
      _ingredientsController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe added successfully!')),
      );
      Navigator.of(context).pop(); // Close dialog
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add recipe: $e')),
      );
    }
  }

  void _showAddRecipeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Recipe'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _recipeNameController,
                  decoration: const InputDecoration(labelText: 'Recipe Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                      labelText: 'Ingredients (separate with new lines)'),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _recipeNameController.clear();
                _descriptionController.clear();
                _ingredientsController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addRecipe,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _signOut() async {
    try {
      await supabase.auth.signOut();
      // Navigation back to login screen after logout is handled by StreamBuilder in main.dart
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out: $e')),
      );
    }
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(
        child: Text(
          'You are not logged in. Please log in to see your recipes.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : StreamBuilder<List<Map<String, dynamic>>>(
        // Listen to changes in recipe data from Supabase
        stream: supabase
            .from('recipes')
            .stream(primaryKey: ['id'])
            .eq('user_id', currentUser.id) // Filter by current user's ID
            .order('created_at', ascending: false), // Order by created_at
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No recipes saved yet. Add your first recipe!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Convert Supabase data (List<Map<String, dynamic>>) into a list of Recipe objects
          final recipes = snapshot.data!.map((map) {
            return Recipe.fromSupabase(map);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      recipe.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    recipe.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    recipe.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(recipe.description),
                          const SizedBox(height: 15),
                          const Text(
                            'Ingredients:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          // Display ingredients as a separate list
                          ...recipe.ingredients.map((ingredient) => Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                            child: Text('• $ingredient'),
                          )),
                          const SizedBox(height: 15),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'Added on: ${recipe.createdAt.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  // Confirm deletion
                                  bool? confirmDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Delete Recipe?'),
                                        content: const Text('Are you sure you want to delete this recipe?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmDelete == true) {
                                    try {
                                      await supabase
                                          .from('recipes')
                                          .delete()
                                          .eq('id', recipe.id); // Delete by recipe ID
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Recipe deleted successfully!')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to delete recipe: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecipeDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
