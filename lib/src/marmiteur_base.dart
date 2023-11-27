import 'dart:convert';             // Contains the JSON encoder
import 'dart:collection';          // To create HashMap
import 'package:http/http.dart';   // Contains a client for making API calls
import 'package:beautiful_soup_dart/beautiful_soup.dart'; // BeautifulSoup

// Fetch userURL webpage
Future suckWebpage(String userURL) async {
	var client = Client();
	final URI = Uri.parse(userURL);
	Response response = await client.get(URI);
	BeautifulSoup bs = BeautifulSoup(response.body);
	return bs;
}

// Check if a recipe is available on the webpage
String? pinpointRecipe(BeautifulSoup bs) {
	RegExp exp = RegExp(r'\s+({.*"@type":"Recipe".*})'); // TODO: generalize
	String str = bs.toString();
	RegExpMatch? match = exp.firstMatch(str);
	return match![0];
}

// Place recipe details in HashMap.
// That is not smart as the JSON is sufficient.
// However, websites won't always provide JSONs
// and this function will be adapted.
Map<String, dynamic> extractRecipe(String? content) {
	// Construct empty HashMap
	Map<String, dynamic> scrapped = HashMap();

	// If "content" is empty, return "empty" HashMap
	// Else go on
	if ( content!.isEmpty ) {
		return scrapped;
	};

	final parsedJson = jsonDecode(content); // Decode the JSON

	// Declare JSON keys names (facilitates future flexibility)
	// (jk for JSON key)
	//     -> adapt depending on scrapped URL
	String jkName = 'name';
	String jkCategory = 'recipeCategory';
	String jkImage = 'image';
	String jkDate = 'datePublished';
	String jkPrepTime = 'prepTime';
	String jkCookTime = 'cookTime';
	String jkTotalTime = 'totalTime';
	String jkYield = 'recipeYield';
	String jkIngredients = 'recipeIngredient';
	String jkInstructions = 'recipeInstructions';
	String jkAuthor = 'author';
	String jkDescription = 'description';
	String jkKeywords = 'keywords';
	String jkCuisine = 'recipeCuisine';
	String jkRating = 'aggregateRating';
	String jkVideo = 'video';

	// "Extract" data from JSON
	String? name = parsedJson[jkName];
	String? category = parsedJson[jkCategory];
	List? image = parsedJson[jkImage]; // images URLs
	String? date = parsedJson[jkDate];
	String? prepTime  = parsedJson[jkPrepTime];
	String? cookTime  = parsedJson[jkCookTime];
	String? totalTime = parsedJson[jkTotalTime];
	String? portion = parsedJson[jkYield];
	List? ingredients = parsedJson[jkIngredients]; // images URLs

	List<String>? instructions = [];
	parsedJson[jkInstructions].forEach((entry) {
		instructions.add(entry['text']); // adjust
		});

	String? author = parsedJson[jkAuthor];
	String? description = parsedJson[jkDescription];
	String? keywords = parsedJson[jkKeywords]; // transform to list?

	String? cuisine = parsedJson[jkCuisine];
	double? rating = parsedJson[jkRating]['ratingValue']; // adjust

	String? video = parsedJson[jkVideo]['contentUrl']; // adjust

	// "Add" data to HashMap
	//Map<String, dynamic> scrapped = HashMap();
	scrapped.addAll({
		"name": name,
		"category": category,
		"image": image,
		"date": date,
		"prepTime": prepTime,
		"cookTime": cookTime,
		"totalTime": totalTime,
		"portion": portion,
		"ingredients": ingredients,
		"instructions": instructions,
		"author": author,
		"description": description,
		"keywords": keywords,
		"cuisine": cuisine,
		"rating": rating
		});
	return scrapped;
}

// Returns a HashMap of the recipe available informations
// For example:
//		import 'package:marmiteur/marmiteur.dart' as marmiteur;
//		var myRecipe = await marmiteurscrapRecipe(userURL);
//              print(myRecipe['name']);
Future<Map<String, dynamic>> marmiteur(String userURL) {
	var res = suckWebpage(userURL).then((value) {
		String? match = pinpointRecipe(value);
		return extractRecipe(match);
		});
	return res;
}
