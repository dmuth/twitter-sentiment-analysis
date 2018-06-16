
require([
    "underscore",
    "splunkjs/mvc",
    "splunkjs/mvc/searchmanager",
    "splunkjs/mvc/tableview",
    "splunkjs/mvc/simplexml/ready!"
], function(_, mvc, SearchManager,
       TableView) {

	//
	// Set up our search.
	//
	var query = mvc.tokenSafe('index=main sourcetype="3-tweets-export-log" username=*$username$* '
		+ '| eval confidence = round(case(sentiment=="POSITIVE", score_positive, '
			+ 'sentiment=="NEGATIVE", score_negative, sentiment=="MIXED", '
			+ 'score_mixed, sentiment=="NEUTRAL", score_neutral) * 100, 2) '
		+ '$high$ '
		+ '| eval confidence_text = confidence . "%" '
		+ '| eval Tweet = username . "-" . tweet_id ."-" . tweet '
		+ '| table _time, sentiment, confidence_text, Tweet '
		+ '| rename sentiment AS Sentiment, confidence_text AS Confidence'
		);

	//
	// Run our search.
	//
        var search1 = new SearchManager({
            id: "mainsearch",
		search: query,
            earliest_time: mvc.tokenSafe("$earliestTime$"),
            latest_time: mvc.tokenSafe("$latestTime$"),
            preview: true,
            cache: true
        });

	//
	// Table API: http://docs.splunk.com/DocumentationStatic/WebFramework/1.0/compref_table.html
	//
        var myCustomTable = new TableView({
            id: "table-custom",
            managerid: "mainsearch",
            el: $("#user-tweets"),
		pageSize: 5,
        });

        // Use the BaseCellRenderer class to create a custom table cell renderer
        var CustomIconCellRenderer = TableView.BaseCellRenderer.extend({ 

            canRender: function(cellData) {
                return cellData.field === 'Tweet';
            },
            
            // This render function only works when canRender returns 'true'
            render: function($td, cellData) {

		var results = cellData.value.split("-");
		var username = results[0];
		var tweet_id = results[1];
		var tweet = results.slice(2).join("-");
                //console.log("cellData: ", username, tweet_id, tweet);

		var html = '<blockquote class="twitter-tweet" data-lang="en" '
			//
			// Hide embedded images
			//
			//+ 'data-cards="hidden" '
			+ '>'
			+ '<p lang="en" dir="ltr"></p>'
			+ '<a href="https://twitter.com/' + username + '/status/' + tweet_id + '?"></a>'
			+ '</blockquote>'
			+ '<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>'
			;


		$td.html(html);

            }
        });
        
        // Create an instance of the custom cell renderer
        var myCellRenderer = new CustomIconCellRenderer();

        // Add the custom cell renderer to the table
        myCustomTable.addCellRenderer(myCellRenderer); 

        // Render the table
        myCustomTable.render();



});


