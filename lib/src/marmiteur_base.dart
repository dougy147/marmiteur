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
	if (matches.length != 0) {
	  var match = matches
	  	      .elementAt(0) // Normally only match
	  	      .group(2)     // 0: full exp, then inside parenthesis
	  	      .toString();  // could be useless
	  return match;
	} else {
	  return "";
	};
}

// Place recipe details in HashMap.
// That is not smart as the JSON is sufficient.
// However, websites won't always provide JSONs
// and this function will be adapted.
Map<String, dynamic> extractRecipe(String? content, bool auto_format) {
	// Construct empty HashMap
	Map<String, dynamic> scrapped = HashMap();

	// If "content" is empty, return "empty" HashMap
	// Else go on
	if ( content!.isEmpty ) { return scrapped; };

	final parsedJson = jsonDecode(content); // Decode the JSON

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

	var toParse = parsedJson;

        // Check if it is a "correct" Json type
	if (toParse.runtimeType != Map<String, dynamic>) {
	  // If json is a list, store first element? (first tries...)
	  if (toParse.runtimeType == List<dynamic>) {
	    if (toParse.length == 1) {
	      toParse = toParse[0];
            };
	  };
	};

        // for each (key,value) in Json, store in scrapped
	toParse.forEach((key, value) {
	  if (keysToExtract.contains(key)) {
	    scrapped[key] = value;
	  }
	});

	// If auto_format == true, then... proceed !
	if ( auto_format ) {
	  scrapped = autoFormat(toParse, keysToExtract , scrapped);
	};

	return scrapped;
}

// Try to extract and prune each piece of information,
// returning it in the correct type (see Documentation).
Map<String, dynamic> autoFormat(var parsedJson , var keysToExtract , Map<String, dynamic> scrapped) {
	// If important key values (like name) are empty BUT not '@graph' try again
	// Name => String
	if (scrapped['name'] == null && scrapped['@graph'] != null) {
	  var subJson = parsedJson['@graph'][0] as Map;
	  subJson.forEach((key, value) {
	    if (keysToExtract.contains(key)) {
	      scrapped[key] = value;
	    }
	  });
	};
	if (scrapped['name'] == null) {
	  scrapped['name'] = "";
	};

	// recipeCategory => List<String?>
	if (scrapped['recipeCategory'] != null) {
	  if ( scrapped['recipeCategory'].runtimeType == String ) {
            RegExp re = RegExp(r'\s*,\s*');
            scrapped['recipeCategory'] = scrapped['recipeCategory'].split(re);
	  }
	} else {
          scrapped['recipeCategory'] = [];
	};

	// TODO: a function we can "recursively" call each time
	// the type changes (same for all other themes)
	// images => List<dynamic>
	if (scrapped['image'] != null && scrapped['image'] != [] ) {
	  if ( scrapped['image'].runtimeType != List<String> ) {
	    if (scrapped['image'].runtimeType == String) {
	      // Provisory? Check if match an image pattern (e.g. .jpg,.webm
              RegExp re = RegExp(r'\.(jpeg|jpg|bmp|webp|png|gif)');
	      if ((re.allMatches(scrapped['image'])).length == 0) {
	        scrapped['image'] = [];
	      } else {
	        scrapped['image'] = [scrapped['image']];
	      };
	    } else if (scrapped['image'].runtimeType == List<dynamic> ) {
	      print("check if element contains a jpeg");
	    } else {
	        scrapped['image'] = scrapped['image']['url'];
		print("Type of image: ${scrapped['image'].runtimeType}");
	        if (scrapped['image'].runtimeType == String) {
	          // Provisory? Check if match an image pattern (e.g. .jpg,.webm
                  RegExp re = RegExp(r'\.(jpeg|jpg|bmp|webp|png|gif)');
	          if ((re.allMatches(scrapped['image'])).length == 0) {
	            scrapped['image'] = [];
	          } else {
	            scrapped['image'] = [scrapped['image']];
	          };
	        };
	    };
	  }
	} else {
          scrapped['image'] = [];
	};


	// (String) publication date
	if (scrapped['datePublished'] == null ) {
	  scrapped['datePublished'] = "";
	};


	// (String) time (prep, cook, total)
	for ( var time in ["prepTime", "cookTime", "totalTime"] ) {
	  if ( scrapped[time] == null ) {
	      scrapped[time] = "";
	    };
	};
	if ( (scrapped['totalTime'] == "") && ( (scrapped['prepTime'] != "" ) || (scrapped['cookTime'] != "") ) ) {
	  if (scrapped['prepTime'] == "") {
	    scrapped['totalTime'] = scrapped['prepTime'];
	  } else if (scrapped['cookTime'] == "") {
	    scrapped['totalTime'] = scrapped['cookTime'];
	  } else {
	    // parse : PT10M .. PT1H55M .. and reconstruct
	    RegExp hour = RegExp(r'(\d+)H');
	    RegExp min = RegExp(r'(\d+)M$');
	    String hour_prep = "0";
	    String hour_cook = "0";
	    String min_prep = "0";
	    String min_cook = "0";
            if (hour.hasMatch(scrapped['prepTime'])) {
	      hour_prep = hour.allMatches(scrapped['prepTime']).elementAt(0).group(1).toString();
	    };
            if (hour.hasMatch(scrapped['cookTime'])) {
	      hour_cook = hour.allMatches(scrapped['cookTime']).elementAt(0).group(1).toString();
	    };
            if (min.hasMatch(scrapped['prepTime'])) {
	      min_prep = min.allMatches(scrapped['prepTime']).elementAt(0).group(1).toString();
	    };
            if (min.hasMatch(scrapped['cookTime'])) {
	      min_cook = min.allMatches(scrapped['cookTime']).elementAt(0).group(1).toString();
	    };
	    int total_min = 60 * int.parse(hour_prep) + 60 * int.parse(hour_cook) + int.parse(min_prep) + int.parse(min_cook);
	    int hours = (total_min / 60).floor();
	    int minutes = (total_min % 60);
	    if ( hours > 0 ) {
	      scrapped['totalTime'] = "PT" + hours.toString() + "H" + minutes.toString() + "M";
	    } else {
	      scrapped['totalTime'] = "PT" + minutes.toString() + "M";
	    };
	  };
	};


	// recipeYield => String?
	if (scrapped['recipeYield'] != null) {
	  if (!(scrapped['recipeYield'].runtimeType == List<dynamic>) || !(scrapped['recipeYield'].runtimeType == List<String>)) {
	    scrapped['recipeYield'] = [scrapped['recipeYield'].toString()];
	  };
	} else {
	  scrapped['recipeYield'] = [];
	};


	// recipeIngredient => List<dynamic>
	if (scrapped['recipeIngredient'] != null) {
	  if ((scrapped['recipeIngredient'].runtimeType == List<dynamic>) || (scrapped['recipeIngredient'].runtimeType == List<String>)) {
	    RegExp ignore_if_match = RegExp(r'^(\s*(Steps?|[ÉéeE]tapes?)\s*\d*\s*)?$');
	    List<dynamic> keepIng = [];
	    scrapped['recipeIngredient'].forEach((ing) {
	      print("Ing: ${ing} (runtimeType: ${ing.runtimeType})");
              if ( (ing.trim().isNotEmpty) && (! ignore_if_match.hasMatch(ing))) {
	        keepIng.add(ing); // append_to_list
	      } else {
	        print("Ignoring '${ing}' from scrapped ingredients.");
	      };
	    });
	    scrapped['recipeIngredient'] = keepIng;
	  } else {
	    print("Unknown INGREDIENTS format. TODO.");
	  };
	} else {
	  scrapped['recipeIngredient'] = [] ;
	};

	// recipeInstructions => List<dynamic>
	if (scrapped['recipeInstructions'] != null) {
	  if ((scrapped['recipeInstructions'].runtimeType == List<dynamic>) || (scrapped['recipeInstructions'].runtimeType == List<String>)) {
	    if ( scrapped['recipeInstructions'][0].runtimeType == String ) {
	      RegExp ignore_if_match = RegExp(r'^(\s*(Steps?|[ÉéeE]tapes?)\s*\d*\s*)?$');
	      List<dynamic> keepIng = [];
	      scrapped['recipeInstructions'].forEach((instr) {
	        print("Instruction: ${instr} (runtimeType: ${instr.runtimeType})");
                if ( (instr.trim().isNotEmpty) && (! ignore_if_match.hasMatch(instr))) {
	          keepIng.add(instr); // append_to_list
	        } else {
	          print("Ignoring '${instr}' from scrapped instructions.");
	        };
	      });
	      scrapped['recipeInstructions'] = keepIng;
	    } else {
	      // this is a json!
	      RegExp ignore_if_match = RegExp(r'^(\s*(Steps?|[ÉéeE]tapes?)\s*\d*\s*)?$');
	      List<dynamic> keepIng = [];
	      scrapped['recipeInstructions'].forEach((instr) {
                if ( (instr['text'].trim().isNotEmpty) && (! ignore_if_match.hasMatch(instr['text']))) {
	          keepIng.add(instr['text']); // append_to_list
	        } else {
	          print("Ignoring '${instr['text']}' from scrapped instructions.");
	        };
	      });
	      scrapped['recipeInstructions'] = keepIng;
	    };
	  } else {
	    print("Unknown INSTRUCTIONS format. TODO.");
	  };
	} else {
	  scrapped['recipeInstructions'] = [] ;
	};
	// UTF-8/HTML decode TODO here


	// author (String)
	if (scrapped['author'] != null) {
	  if (scrapped['author'].runtimeType != String) {
	    if (scrapped['author'].runtimeType == List<dynamic>) {
	      scrapped['author'] = scrapped['author'][0]['name'];
	    } else {
	      scrapped['author'] = scrapped['author']['name'];
	    };
	  };
	} else {
	  scrapped['author'] = "";
	};

	//// keywords (List<String>)
	if (scrapped['keywords'] != null) {
	  if (scrapped['keywords'].runtimeType != List<dynamic>) {
	    if (scrapped['keywords'].runtimeType == String) {
              RegExp re = RegExp(r'\s*,\s*');
              scrapped['keywords'] = scrapped['keywords'].split(re);
	      List<dynamic> keepIng = [];
	      scrapped['keywords'].forEach((key) {
                if ( key.trim().isNotEmpty ) {
	          keepIng.add(key); // append_to_list
	        };
	      });
	      scrapped['keywords'] = keepIng;
	    };
	  };
	} else {
	  scrapped['keywords'] = [];
	};

	//// description (String)
	if (scrapped['description'] == null) {
	  scrapped['description'] = [];
	}

	//// recipeCuisine (List<String>)
	if (scrapped['recipeCuisine'].runtimeType != List<String>) {
	  if (scrapped['recipeCuisine'] == null) {
	    scrapped['recipeCuisine'] = [];
	  } else if ( scrapped['recipeCuisine'].runtimeType == String ) {
	    scrapped['recipeCuisine'] = [scrapped['recipeCuisine']];
	  };
	}

	//// TODO: rating

	//// video (List<String>)
	if (scrapped['video'].runtimeType != List<String>) {
	  if (scrapped['video'] == null) {
	    scrapped['video'] = [];
	  } else if ( scrapped['video'].runtimeType == String ) {
	    scrapped['video'] = [scrapped['video']];
	  } else {
	    scrapped['video'] = [scrapped['video']['contentUrl']];
	  };
	}

	return scrapped;
}

// Returns a HashMap of the recipe available informations
// For example:
//		import 'package:marmiteur/marmiteur.dart' as marmiteur;
//		var myRecipe = await marmiteurscrapRecipe(userURL);
//              print(myRecipe['name']);
Future<Map<String, dynamic>> marmiteur(String userURL, { bool auto_format = true , bool print_output = false}) {
	var res = suckWebpage(userURL).then((value) {
		String? match = pinpointRecipe(value);
		return extractRecipe(match, auto_format); // auto_format (true by default) => outputs standardized types
		});
	return res;
}
