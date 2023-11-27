import 'package:marmiteur/marmiteur.dart';

void main() async {
  String recipeURL = "http://www.marmiton.org/recettes/recette_burger-d-avocat_345742.aspx";
  var recipe = await marmiteur(recipeURL);
  print(recipe['name']);
  print(recipe['ingredients']);
  print(recipe['instructions']);
  print(recipe['image']);
}
