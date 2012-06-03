$(document).ready(function(){

    // slide everything open on new page
    $(".outline:hidden").slideToggle("slow", function(){
        $(".percent:hidden").fadeIn("slow");
    });

    // re-activate links (the event is stomped on by the li event)
    $(".outline a").click(function(){ window.location.href = this });

    // highlight clicked items
    $("li").not("[ul]").click(function(){ $(this).toggleClass("selected") });

    // add line numbers
    var line_counter = 0;
    $("li").each(function(){
        var str = '<span class="linenum">' + ++line_counter + ':</span>';
        $(this).prepend(str);
    });

    // attach folds
    $(".outline ul li").toggle(

        // hide
        function(){
            if ( $(this).children("ul").size() == 0 ) return;
            $(this).children("ul").slideUp("slow");
            $(this).find(".linenum").addClass("linenum-folded");
        },

        // show
        function(){
            $(this).children("ul").slideDown("slow");
            $(this).find(".linenum").removeClass("linenum-folded");
        }
    );

});
