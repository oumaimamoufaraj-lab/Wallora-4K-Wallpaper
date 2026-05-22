import 'dart:math';

class WallpaperCatalog {
  WallpaperCatalog._();

  static const int popularGridCount = 8;

  static const List<String> anime = [
    'assets/anime_1-a5896858-0fd3-4242-a08e-07f74130d5cf.png',
    'assets/anime_2-07b3ce61-c3fc-4299-854a-369b6935e470.png',
    'assets/anime_3-b758349b-e4db-47b3-9627-91c24766e1c0.png',
    'assets/anime_4-0ebce553-a87c-4828-95bf-0e94608085a4.png',
    'assets/anime_5-55676eaf-e26a-4063-9423-9becd34ed252.png',
    'assets/anime_6-d387533f-ed84-4b24-b9e5-9b2e630dfc6f.png',
    'assets/anime_7-cb3b6d8d-4101-4735-9fd8-38f747ffd380.png',
    'assets/anime_8-d8aebae4-4244-4e82-98cf-8a6c2cdf119c.png',
  ];

  static const List<String> sports = [
    'assets/sport_1-3a70c07f-e2b0-41a6-b616-bbedf781f6e0.png',
    'assets/sport_2-4c01cb7c-e9cd-48c1-8541-b45e96a57834.png',
    'assets/sport_3-24069d82-8a2a-471b-b593-b61722025084.png',
    'assets/sport_4-b0f8b769-ecfe-4a26-b74f-2460ec38ca36.png',
    'assets/sport_5-e0f75e7e-167b-46f1-bc37-c72295a92a48.png',
    'assets/sport_6-329ff2fa-18a3-4f9e-a5f0-065c8c2b79dc.png',
    'assets/sport_7-e1eecd45-72f3-4a2b-90dd-657cc759b5c0.png',
    'assets/sport_8-8a5dbc94-366d-4d68-acd5-4c40ae396f40.png',
  ];

  static const List<String> fantastic = [
    'assets/Fantastic_1-0a4ee99d-5b14-436e-88b4-baa3b70b9f2a.png',
    'assets/Fantastic_2-5893cbb0-e8d2-4a35-9272-c48a56069a97.png',
    'assets/Fantastic_3-3ba5ded9-9514-42c1-a246-db6c7d85f1c7.png',
    'assets/Fantastic_4-6e69adfc-b9ef-4f63-833b-428d5bbb0f0c.png',
    'assets/Fantastic_6-0223dbca-6562-4099-a9da-0f446f18644a.png',
    'assets/Fantastic_7-077af381-63b1-45ca-8621-5ce450fba6be.png',
    'assets/Fantastic_8-d5185b22-9294-4444-9d41-9b92e3f856ca.png',
    'assets/Fantastic_9-24e8d5cd-2752-436a-97b2-aaa5037a9e25.png',
  ];

  static const List<String> minimalist = [
    'assets/minimal_1-206ac673-d34f-401c-a01d-78ad01a20acd.png',
    'assets/minimal_2-ef4ddcad-87c6-4ddf-9995-0959d710732d.png',
    'assets/minimal_3-0d49c29c-8545-4845-927a-22266c52d61a.png',
    'assets/minimal_4-8f8b9db7-3976-400e-96ac-6022128c413b.png',
    'assets/minimal_5-2819bf6d-83f2-49f3-ad6d-f753a160e5f9.png',
    'assets/minimal_6-89a26e6d-5f31-4549-be83-187878bdffe8.png',
    'assets/minimal_7-94399433-5d35-491c-b5e8-d69b47cbb625.png',
    'assets/minimal_8-c5b482d4-db8b-4a2c-9eca-92c0a6ac75c7.png',
  ];

  static final Set<String> allPaths = {
    ...anime,
    ...sports,
    ...fantastic,
    ...minimalist,
  };

  static List<String> pickPopularRandom({int count = popularGridCount}) {
    final pool = allPaths.toList()..shuffle(Random());
    return pool.take(count).toList();
  }

  static bool isValidAsset(String path) => allPaths.contains(path);
}
