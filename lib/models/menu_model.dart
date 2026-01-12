class MenuModel {
  final int id;
  final String menu;
  final String? image;
  final String kcal;
  final Nutrisi nutrisi;
  final List<KomponenPiring> komponen;

  MenuModel({
    required this.id,
    required this.menu,
    this.image,
    required this.kcal,
    required this.nutrisi,
    required this.komponen,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    var list = json['komponen'] as List;
    List<KomponenPiring> komponenList = list.map((i) => KomponenPiring.fromJson(i)).toList();

    return MenuModel(
      id: json['id'],
      menu: json['menu'],
      image: json['image'],
      kcal: json['kcal'],
      nutrisi: Nutrisi.fromJson(json['nutrisi']),
      komponen: komponenList,
    );
  }
}

class Nutrisi {
  final Map<String, String> karbo;
  final Map<String, String> prot;
  final Map<String, String> lem;
  final String serat;
  final String zatBesi;
  final String kalsium;

  Nutrisi({
    required this.karbo,
    required this.prot,
    required this.lem,
    required this.serat,
    required this.zatBesi,
    required this.kalsium,
  });

  factory Nutrisi.fromJson(Map<String, dynamic> json) {
    return Nutrisi(
      karbo: Map<String, String>.from(json['karbo']),
      prot: Map<String, String>.from(json['prot']),
      lem: Map<String, String>.from(json['lem']),
      serat: json['serat'],
      zatBesi: json['zat_besi'],
      kalsium: json['kalsium'],
    );
  }
}

class KomponenPiring {
  final String n; // Nama
  final String b; // Berat
  final String c; // Kode Warna Hex

  KomponenPiring({required this.n, required this.b, required this.c});

  factory KomponenPiring.fromJson(Map<String, dynamic> json) {
    return KomponenPiring(
      n: json['n'],
      b: json['b'],
      c: json['c'],
    );
  }
}