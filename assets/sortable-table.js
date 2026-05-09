"use strict";
/*!
 * @copyright Copyright (C) 2015-2026 AIZAWA Hina
 * @license https://github.com/fetus-hina/stat.ink/blob/master/LICENSE MIT
 * @author AIZAWA Hina <hina@fetus.jp>
 */
(($) => {
    $('.table-sortable')
        .stupidtable()
        .on('aftertablesort', function (_event, data) {
        const th = $(this).find('th');
        th.find('.arrow').remove();
        th.eq(data.column)
            .append(' ')
            .append($('<span>')
            .addClass('arrow fas')
            .addClass(data.direction === $.fn.stupidtable.dir.ASC ? 'fa-angle-up' : 'fa-angle-down'));
    });
})(jQuery);
