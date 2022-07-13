import 'dart:io';
import 'dart:math';
import 'package:grpc/grpc.dart';
import 'package:grpc_dart_server/dart_grpc_server.dart';

class Client {
  ClientChannel? channel;
  GroceriesServiceClient? stub;
  var response;
  bool excutionInProgress = true;

  Future<Category> _findCategoryByName(String name) async {
    var category = await stub!.getCategory(Category()..name = name);
    return category;
  }

  Future<Item> _findItemByName(String name) async {
    var item = await stub!.getItem(Item()..name = name);
    return item;
  }

  int _random() => Random(1000).nextInt(9999);

  Future<void> main() async {
    channel = ClientChannel(
      'localhost',
      port: 60000,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    stub = GroceriesServiceClient(
      channel!,
      options: CallOptions(
        timeout: Duration(seconds: 30),
      ),
    );

    while (excutionInProgress) {
      try {
        print('---- Welcome to the dart store API ---');
        print('   ---- what do you want to do? ---');
        print('👉 1: View all products');
        print('👉 2: Add new product');
        print('👉 3: Edit product');
        print('👉 4: Get product');
        print('👉 5: Delete product \n');
        print('👉 6: View all categories');
        print('👉 7: Add new category');
        print('👉 8: Edit category');
        print('👉 9: Get category');
        print('👉 10: Delete category \n');
        print('👉 11: Get all products of given category');

        var option = int.parse(stdin.readLineSync()!);

        switch (option) {
          case 1:
            response = await stub!.getAllItems(Empty());
            print(' --- Store products --- ');
            response.items.forEach((item) {
              print(
                  '✅: ${item.name} (id: ${item.id} | categoryId: ${item.categoryId})');
            });
            break;
          case 2:
            print('Enter product name');
            var name = stdin.readLineSync()!;
            var item = await _findItemByName(name);
            if (item.id != 0) {
              print(
                  '🔴 product already exists: name ${item.name} | id: ${item.id} ');
            } else {
              print('Enter product\'s category name');
              var categoryName = stdin.readLineSync()!;
              var category = await _findCategoryByName(categoryName);
              if (category.id == 0) {
                print(
                    '🔴 category $categoryName does not exists, try creating it first');
              } else {
                item = Item()
                  ..name = name
                  ..id = _random()
                  ..categoryId = category.id;
                response = await stub!.createItem(item);
                print(
                    '✅ product created | name ${response.name} | id ${response.id} | category id ${response.categoryId}');
              }
            }

            break;

          case 3:
            print('Enter product name');
            var name = stdin.readLineSync()!;
            var item = await _findItemByName(name);
            if (item.id != 0) {
              print('Enter new product name');
              name = stdin.readLineSync()!;
              response = await stub!.editItem(
                  Item(id: item.id, name: name, categoryId: item.categoryId));
              if (response.name == name) {
                print(
                    '✅ product updated | name ${response.name} | id ${response.id}');
              } else {
                print('🔴 product update failed 🥲');
              }
            } else {
              print('🔴 product $name not found, try creating it!');
            }
            break;
          case 4:
            print('Enter product name');
            var name = stdin.readLineSync()!;
            var item = await _findItemByName(name);
            if (item.id != 0) {
              print(
                  '✅ product found | name ${item.name} | id ${item.id} | category id ${item.categoryId}');
            } else {
              print('🔴 product not found | no product matches the name $name');
            }
            break;
          case 5:
            print('Enter product name');
            var name = stdin.readLineSync()!;
            var item = await _findItemByName(name);
            if (item.id != 0) {
              await stub!.deleteItem(item);
              print('✅ item deleted');
            } else {
              print('🔴 product $name does not exist ');
            }

            break;
          case 6:
            response = await stub!.getAllCategories(Empty());
            print(' --- Store product categories --- ');
            response.categories.forEach((category) {
              print('👉: ${category.name} (id: ${category.id})');
            });

            break;
          case 7:
            print('Enter category name');
            var name = stdin.readLineSync()!;
            var category = await _findCategoryByName(name);
            if (category.id != 0) {
              print(
                  '🔴 category already exists: category ${category.name} (id: ${category.id})');
            } else {
              category = Category()
                ..id = Random(999).nextInt(9999)
                ..name = name;
              response = await stub!.createCategory(category);
              print(
                  '✅ category created: name ${category.name} (id: ${category.id})');
            }
            break;
          case 8:
            print('Enter category name');
            var name = stdin.readLineSync()!;
            var category = await _findCategoryByName(name);
            if (category.id != 0) {
              print('Enter new category name');
              name = stdin.readLineSync()!;
              response = await stub!
                  .editCategory(Category(id: category.id, name: name));
              if (response.name == name) {
                print(
                    '✅ category updated | name ${response.name} | id ${response.id}');
              } else {
                print('🔴 category update failed 🥲');
              }
            } else {
              print('🔴 category $name not found, try creating it!');
            }

            break;
          case 9:
            print('Enter category name');
            var name = stdin.readLineSync()!;
            var category = await _findCategoryByName(name);
            if (category.id != 0) {
              print(
                  '✅ category found | name ${category.name} | id ${category.id}');
            } else {
              print(
                  '🔴 category not found | no category matches the name $name');
            }

            break;
          case 10:
            print('Enter category name');
            var name = stdin.readLineSync()!;
            var category = await _findCategoryByName(name);
            if (category.id != 0) {
              await stub!.deleteCategory(category);
              print('✅ category deleted');
            } else {
              print('🔴 category $name not found ');
            }
            break;
          case 11:
            print('Enter category name');
            var name = stdin.readLineSync()!;
            var category = await _findCategoryByName(name);
            if (category.id != 0) {
              var _result = await stub!.getItemsByCategory(category);
              print('--- all products of the $name category --- ');

              _result.items.forEach((item) {
                print('👉 ${item.name}');
              });
            } else {
              print('🔴 category $name not found');
            }

            break;
          default:
            print('invalid option 🥲');
        }
      } catch (e) {
        print(e);
      }
      print('Do you wish to exit the store? (y/n)');
      var input = stdin.readLineSync() ?? 'y';
      excutionInProgress = input.toLowerCase() != 'y';
    }

    await channel!.shutdown();
  }
}

void main(List<String> args) {
  var client = Client();
  client.main();
}
