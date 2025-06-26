import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/recipe.dart';

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
        const SnackBar(content: Text('Semua bidang harus diisi!')),
      );
      return;
    }

    final User? currentUser  = supabase.auth.currentUser ;
    if (currentUser  == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk menambah resep.')),
      );
      return;
    }

    try {
      
      await supabase.from('recipes').insert({
        'user_id': currentUser .id,
        'name': _recipeNameController.text,
        'description': _descriptionController.text,
        'ingredients': _ingredientsController.text.split('\n'),
      });

      
      _recipeNameController.clear();
      _descriptionController.clear();
      _ingredientsController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resep berhasil ditambahkan!')),
      );

      
      setState(() {});

      Navigator.of(context).pop(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan resep: $e')),
      );
    }
  }

  Future<void> _editRecipe(Recipe recipe) async {
    if (_recipeNameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _ingredientsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua bidang harus diisi!')),
      );
      return;
    }

    final User? currentUser  = supabase.auth.currentUser ;
    if (currentUser  == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk mengedit resep.')),
      );
      return;
    }

    try {
      
      await supabase.from('recipes').update({
        'name': _recipeNameController.text,
        'description': _descriptionController.text,
        'ingredients': _ingredientsController.text.split('\n'),
      }).eq('id', recipe.id);

      
      _recipeNameController.clear();
      _descriptionController.clear();
      _ingredientsController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resep berhasil diperbarui!')),
      );

      
      setState(() {});

      Navigator.of(context).pop(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui resep: $e')),
      );
    }
  }

  
  void _showAddRecipeDialog() {
    
    _recipeNameController.clear();
    _descriptionController.clear();
    _ingredientsController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Resep Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _recipeNameController,
                  decoration: const InputDecoration(labelText: 'Nama Resep'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                      labelText: 'Bahan-bahan (pisahkan dengan baris baru)'),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: _addRecipe,
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  
  void _showEditRecipeDialog(Recipe recipe) {
    
    _recipeNameController.text = recipe.name;
    _descriptionController.text = recipe.description;
    _ingredientsController.text = recipe.ingredients.join('\n'); 

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Resep'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _recipeNameController,
                  decoration: const InputDecoration(labelText: 'Nama Resep'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                      labelText: 'Bahan-bahan (pisahkan dengan baris baru)'),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                
                _recipeNameController.clear();
                _descriptionController.clear();
                _ingredientsController.clear();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => _editRecipe(recipe), 
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  
  void _signOut() async {
    try {
      await supabase.auth.signOut();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
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
        automaticallyImplyLeading: false,
        title: const Text('Resepku'),
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
          'Anda belum login. Silakan login untuk melihat resep Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : StreamBuilder<List<Map<String, dynamic>>>(
        
        stream: supabase
            .from('recipes')
            .stream(primaryKey: ['id'])
            .eq('user_id', currentUser.id) 
            .order('created_at', ascending: false), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada resep yang disimpan. Tambahkan resep pertama Anda!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          
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
                            'Deskripsi:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(recipe.description),
                          const SizedBox(height: 15),
                          const Text(
                            'Bahan-bahan:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          
                          ...recipe.ingredients.map((ingredient) => Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                            child: Text('• $ingredient'),
                          )),
                          const SizedBox(height: 15),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'Ditambahkan pada: ${recipe.createdAt.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _showEditRecipeDialog(recipe); 
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  
                                  bool? confirmDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Hapus Resep?'),
                                        content: const Text('Anda yakin ingin menghapus resep ini?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Batal'),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
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
                                      await supabase.from('recipes').delete().eq('id', recipe.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Resep berhasil dihapus!')),
                                      );

                                      
                                      setState(() {});
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Gagal menghapus resep: $e')),
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
