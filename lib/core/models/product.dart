class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.stock,
    required this.status,
    this.oldPrice,
    this.featured = false,
    this.imageId,
    this.imageDataUrl,
    this.imageIds = const [],
    this.imagesDataUrls = const [],
    this.brand,
    this.condition,
    this.specs = const {},
    this.width,
    this.height,
    this.length,
    this.weight,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final int stock;
  final String status;
  final double? oldPrice;
  final bool featured;
  final String? imageId;
  final String? imageDataUrl;
  final List<String> imageIds;
  final List<String> imagesDataUrls;

  // Ficha técnica
  final String? brand;
  final String? condition; // Novo, Usado, Seminovo
  final Map<String, String> specs; // Atributos dinâmicos: {'Memória RAM': '8GB', 'Armazenamento': '256GB SSD', etc}

  // Medidas da embalagem para cotação de frete (cm e kg).
  final double? width;
  final double? height;
  final double? length;
  final double? weight;

  /// Retorna todas as imagens em DataURL disponíveis para exibição
  List<String> get allImages {
    final list = <String>[];
    if (imagesDataUrls.isNotEmpty) {
      list.addAll(imagesDataUrls.where((url) => url.isNotEmpty));
    }
    if (list.isEmpty && imageDataUrl != null && imageDataUrl!.isNotEmpty) {
      list.add(imageDataUrl!);
    }
    return list;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImageIds = json['imageIds'];
    final imageIdsList = rawImageIds is List
        ? rawImageIds.map((e) => e.toString()).toList()
        : <String>[];

    final rawImagesDataUrls = json['imagesDataUrls'];
    final imagesDataUrlsList = rawImagesDataUrls is List
        ? rawImagesDataUrls.map((e) => e.toString()).toList()
        : <String>[];

    final rawSpecs = json['specs'];
    final specsMap = <String, String>{};
    if (rawSpecs is Map) {
      rawSpecs.forEach((k, v) {
        if (k != null && v != null && v.toString().trim().isNotEmpty) {
          specsMap[k.toString()] = v.toString();
        }
      });
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _asDouble(json['price']),
      oldPrice: json['oldPrice'] == null ? null : _asDouble(json['oldPrice']),
      stock: _asDouble(json['stock']).toInt(),
      status: json['status']?.toString() ?? 'inactive',
      featured: json['featured'] == true,
      imageId: json['imageId']?.toString() ?? (imageIdsList.isNotEmpty ? imageIdsList.first : null),
      imageDataUrl: json['imageDataUrl']?.toString() ?? (imagesDataUrlsList.isNotEmpty ? imagesDataUrlsList.first : null),
      imageIds: imageIdsList,
      imagesDataUrls: imagesDataUrlsList,
      brand: json['brand']?.toString(),
      condition: json['condition']?.toString(),
      specs: specsMap,
      width: json['width'] == null ? null : _asDouble(json['width']),
      height: json['height'] == null ? null : _asDouble(json['height']),
      length: json['length'] == null ? null : _asDouble(json['length']),
      weight: json['weight'] == null ? null : _asDouble(json['weight']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'oldPrice': oldPrice,
        'stock': stock,
        'status': status,
        'featured': featured,
        'imageId': imageId ?? (imageIds.isNotEmpty ? imageIds.first : null),
        'imageIds': imageIds,
        'brand': brand,
        'condition': condition,
        'specs': specs,
        'width': width,
        'height': height,
        'length': length,
        'weight': weight,
      };
}

double _asDouble(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
