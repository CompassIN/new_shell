//nsl_search_var(try, PAGE=findflight, LB="mylb{try}", RB="myrb{try}", LBMATCH=FIRST, SaveOffset=0, ActionOnNotFound=Error, Search=ALL, RETAINPREVALUE="YES", EncodeMode=None, LB_RB_TYPE=NS_SEARCH_VAR_LB_RB);
//nsl_search_var(test, PAGE=index_html, LB="text/h", RB/RE="l;", LBMATCH=FIRST, SaveOffset=0, RETAINPREVALUE="YES", EncodeMode=None);

//nsl_random_number_var(number, Min=1, Max=3, Format=%01lu, Refresh=USE);
nsl_search_var(test, PAGE=index_html, LB/RE="\"offering\":{\"href\":\"/", RB="\"}", LBMATCH=FIRST, SaveOffset=0, RETAINPREVALUE="YES", EncodeMode=None);
