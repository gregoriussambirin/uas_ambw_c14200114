class Recipe {
  final String id; 
  final String userId; 
  final String name;
  final String description;
  final List<dynamic> ingredients; 
  final DateTime createdAt; 

  Recipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.createdAt,
  });

  
  factory Recipe.fromSupabase(Map<String, dynamic> data) {
    
    
    return Recipe(
      id: data['id'] as String, 
      userId: data['user_id'] as String, 
      name: data['name'] as String? ?? 'No Name', 
      description: data['description'] as String? ?? 'No Description',
      ingredients: (data['ingredients'] as List<dynamic>?) ?? [], 
      createdAt: DateTime.parse(data['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  
  Map<String, dynamic> toSupabase() {
    return {
      'user_id': userId,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      
    };
  }
}
