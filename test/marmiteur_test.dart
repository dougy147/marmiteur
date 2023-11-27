import 'package:marmiteur/marmiteur.dart';
import 'package:test/test.dart';

void main() async {
	String userURL = "INSERT_URL_RECIPE_HERE";
	var recipe = await marmiteur(userURL);
	print(recipe);
}
