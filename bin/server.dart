import 'package:grpc/grpc.dart';
import 'package:grpc_dart_server/dart_grpc_server.dart';

class Grocerieservice extends GroceriesServiceBase {
  @override
  Future<Category> createCategory(ServiceCall call, Category request) async =>
      categoriesService.createCategory(request)!;

  @override
  Future<Item> createItem(ServiceCall call, Item request) async =>
      itemsService.createItem(request)!;

  @override
  Future<Empty> deleteCategory(ServiceCall call, Category request) async =>
      categoriesService.deleteCategory(request)!;

  @override
  Future<Empty> deleteItem(ServiceCall call, Item request) async =>
      itemsService.deleteItem(request)!;

  @override
  Future<Category> editCategory(ServiceCall call, Category request) async =>
      categoriesService.editCategory(request)!;

  @override
  Future<Item> editItem(ServiceCall call, Item request) async =>
      itemsService.editItem(request)!;

  @override
  Future<Categories> getAllCategories(ServiceCall call, Empty request) async =>
      Categories()..categories.addAll(categoriesService.getCategories()!);

  @override
  Future<Items> getAllItems(ServiceCall call, Empty request) async =>
      Items()..items.addAll(itemsService.getItems()!);

  @override
  Future<Category> getCategory(ServiceCall call, Category request) async =>
      categoriesService.getCategoryById(request.id)!;

  @override
  Future<Item> getItem(ServiceCall call, Item request) async =>
      itemsService.getItemById(request.id)!;


  @override
  Future<AllItemsOfCategory> getItemsByCategory(
      ServiceCall call, Category request) async =>
      AllItemsOfCategory()
        ..items.addAll(itemsService.getItemsByCategory(request.id)!);
  
}

Future<void> main(List<String> args) async {
  final server = Server(
    [
      Grocerieservice(),
    ],
    const <Interceptor>[],
    CodecRegistry(
      codecs: const [
        IdentityCodec(),
      ],
    ),
  );

  await server.serve(port: 60000);

  print('✅ ✅ ✅ Server listening on port ${server.port}...');
}
