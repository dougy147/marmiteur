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
  print(recipe['ingredients']);
  print(recipe['instructions']);
  print(recipe['image']);
}
```
Also look at [pub.dev/packages/marmiteur](https://pub.dev/packages/marmiteur/install) package installation instructions.

## Usage

```dart
var recipe = await marmiteur(recipeURL);
```

The main function `marmiteur()` returns a HashMap of all scrapped informations about the recipe. The keys it can be called with are listed in the following table. (Almost all self-explanatory.)

| Key           | Type   | Value description                                 |
|---------------|--------|---------------------------------------------------|
| `name`        | String | Name of the recipe                                |
| `category`    | String | Recipe category (cocktail, chili...)              |
| `cuisine`     | String | Cuisine type (starter, main course, dessert...)   |
| `image`       | List   | Link to a photograph of the meal (if any)         |
| `video`       | String | Link to an instruction video (if any)             |
| `prepTime`    | String | -                                                 |
| `cookTime`    | String |                                                   |
| `totalTime`   | String | prepTime + cookTime                               |
| `portion`     | String | Eaters number                                     |
| `ingredients` | List   | -                                                 |
| `instructions`| List   | -                                                 |
| `author`      | String | -                                                 |
| `description` | String | -                                                 |
| `keywords`    | String | -                                                 |
| `rating`      | double | -                                                 |
| `date`        | String | Publication date                                  |

## Additional information

Version `1.0.0` only works for a limited number of websites.
Feel free to contribute to this package to expand it.
