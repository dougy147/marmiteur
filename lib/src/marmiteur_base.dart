import 'dart:convert';             // Contains the JSON encoder
import 'dart:collection';          // To create HashMap
import 'package:http/http.dart';   // Contains a client for making API calls
import 'package:beautiful_soup_dart/beautiful_soup.dart'; // BeautifulSoup

// Fetch userURL webpage
Future suckWebpage(String userURL) async {
	var client = Client();
	final finalURI = Uri.parse(userURL);
	Response response = await client.get(finalURI);
	BeautifulSoup bs = BeautifulSoup(response.body);
	return bs;
}

// Check if a recipe is available on the webpage
String? pinpointRecipe(BeautifulSoup bs) {
	String str = bs.toString();
	RegExp exp = RegExp(r'<script\s+.*?type=\"application\/ld\+json\"\s*?.*?>(\n|\s)*?((\[|\{)(\n|\s)*?((.*?\n)*?|.*?)\s*"@type"\s*?:\s*?(\[)?\s*?"Recipe"(.|\s|\n)*?)<\/script>');
	var matches = exp.allMatches(str);
	////print(matches);
	var match = matches
		      .elementAt(0) // Normally only match
		      .group(2)     // 0: full exp, then inside parenthesis
		      .toString();  // could be useless
	//print(match);
	return match;
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
	print(parsedJson);

	// Keys of interest
	var keysToExtract = [
	  'name',
	  'recipeCategory',
	  'image',
	  'datePublished',
	  'prepTime',
	  'cookTime',
	  'totalTime',
	  'recipeYield',
	  'recipeIngredient',
	  'recipeInstructions',
	  'author',
	  'description',
	  'keywords',
	  'recipeCuisine',
	  'aggregateRating',
	  'video',
	  '@graph',
	];

	parsedJson.forEach((key, value) {
	  if (keysToExtract.contains(key)) {
	    //print('key: $key');
	    //print('value: $value');
	    scrapped[key] = value;
	  }
	});

	// If important key values (like name) are empty BUT not '@graph' try again
	if (scrapped['name'] == null && scrapped['@graph'] != null) {
	  var subJson = parsedJson['@graph'][0] as Map;
	  subJson.forEach((key, value) {
	    if (keysToExtract.contains(key)) {
	      //print('key: $key');
	      //print('value: $value');
	      scrapped[key] = value;
	    }
	  });
	};
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
