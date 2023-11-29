import 'package:marmiteur/marmiteur.dart';

void main() async {
  //String recipeURL = "https://www.marmiton.org/recettes/recette_burger-d-avocat_345742.aspx";
  String recipeURL = "https://www.750g.com/plancha-de-crevettes-marinees-a-la-moutarde-r86001.htm";
  var recipe = await marmiteur(recipeURL);
  print(recipe['name']);
  print(recipe['recipeIngredient']);
  print(recipe['recipeInstructions']);
  print(recipe['image']);
}
