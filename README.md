<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

Extract recipe details given a URL.

## Getting started

```dart
import 'package:marmiteur/marmiteur.dart';

void main() async {
  String recipeURL = "https://www.marmiton.org/recettes/recette_burger-d-avocat_345742.aspx";
  var recipe = await marmiteur(recipeURL);
  print(recipe['name']);
  print(recipe['recipeIngredient']);
  print(recipe['recipeInstructions']);
  print(recipe['image']);
}
```
Also look at [pub.dev/packages/marmiteur](https://pub.dev/packages/marmiteur/install) package installation instructions.

## Usage

```dart
var recipe = await marmiteur(recipeURL); // recipeURL is a String
var recipe = await marmiteur(recipeURL, auto_format = false); // unformated output
```

The main function `marmiteur()` returns a HashMap of all scrapped informations about the recipe. The keys it can be called with are listed in the following table. (Almost all self-explanatory.)

Be aware that the *default type* refers to the one outputed when using `auto_format=true` in the main `marmiteur()` function (by default).

| Key                 | Default type  | Value description                                 |
|---------------------|---------------|---------------------------------------------------|
| `name`              | String        | Name of the recipe                                |
| `recipeCategory`    | List<String>  | Recipe category (cocktail, chili...)              |
| `recipeCuisine`     | List<String>  | Cuisine type (starter, main course, dessert...)   |
| `image`             | List<String>  | Link to a photograph of the meal (if any)         |
| `video`             | List<String>  | Link to an instruction video (if any)             |
| `prepTime`          | String        | -                                                 |
| `cookTime`          | String        | -                                                 |
| `totalTime`         | String        | prepTime + cookTime                               |
| `recipeYield`       | List<String>  | Portion (Number of persons to eat)                |
| `recipeIngredient`  | List<String>  | -                                                 |
| `recipeInstructions`| List<String>  | -                                                 |
| `author`            | String        | -                                                 |
| `description`       | String        | -                                                 |
| `keywords`          | List<String>  | -                                                 |
| `datePublished`     | String        | Publication date                                  |

## Additional information

Version `3.0.0` works for a limited number of websites but should be enough for the painful work.
Feel free to contribute to this package to expand it.
