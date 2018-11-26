($ => {
  $('.table-sortable')
    .stupidtable()
    .on("aftertablesort", function (event, data) {
      const th = $(this).find("th");
      th.find(".arrow").remove();
      th.eq(data.column)
        .append(' ')
        .append(
          $('<span>')
            .addClass('arrow fas')
            .addClass(
              data.direction === $.fn.stupidtable.dir.ASC ? "fa-angle-up" : "fa-angle-down"
            )
        );
     });
})(jQuery);
