<?php

/**
 * @copyright Copyright (C) 2015-2021 AIZAWA Hina
 * @license https://github.com/fetus-hina/stat.ink/blob/master/LICENSE MIT
 * @author AIZAWA Hina <hina@fetus.jp>
 */

declare(strict_types=1);

namespace statink\yii2\sortableTable;

use yii\web\AssetBundle;

class SortableTableAsset extends AssetBundle
{
    public $sourcePath = '@vendor/statink/yii2-sortable-table/assets';
    public $js = [
        'sortable-table.min.js',
    ];
    public $depends = [
        JqueryStupidTableAsset::class,
        // FontAwesomeAsset::class,
    ];
}
