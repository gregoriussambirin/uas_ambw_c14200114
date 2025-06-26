class Recipe {
  final String id; // UUID dari Supabase
  final String userId; // user_id dari Supabase Auth
  final String name;
  final String description;
  final List<dynamic> ingredients; // Supabase mengembalikan List<dynamic> untuk text[]
  final DateTime createdAt; // created_at dari Supabase

  Recipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.createdAt,
  });

  // Factory constructor untuk membuat objek Recipe dari Map Supabase
  factory Recipe.fromSupabase(Map<String, dynamic> data) {
    // Pastikan semua data yang diakses tidak null sebelum di-cast
    // Gunakan pengecekan null yang aman dan berikan nilai default jika null
    return Recipe(
      id: data['id'] as String, // ID harus selalu ada jika ini dari database
      userId: data['user_id'] as String, // user_id harus selalu ada jika RLS benar
      name: data['name'] as String? ?? 'No Name', // Tambahkan 'as String?' untuk null safety
      description: data['description'] as String? ?? 'No Description',
      ingredients: (data['ingredients'] as List<dynamic>?) ?? [], // Cast ke List<dynamic>? lalu berikan default
      createdAt: DateTime.parse(data['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  // Metode untuk mengonversi objek Recipe menjadi Map untuk disimpan di Supabase
  Map<String, dynamic> toSupabase() {
    return {
      'user_id': userId,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      // created_at akan diisi otomatis oleh Supabase saat insert
    };
  }
}
