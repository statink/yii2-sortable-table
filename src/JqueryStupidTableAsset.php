<?php

/**
 * @copyright Copyright (C) 2015-2021 AIZAWA Hina
 * @license https://github.com/fetus-hina/stat.ink/blob/master/LICENSE MIT
 * @author AIZAWA Hina <hina@fetus.jp>
 */

declare(strict_types=1);

namespace statink\yii2\sortableTable;

use yii\web\AssetBundle;
use yii\web\JqueryAsset;

class JqueryStupidTableAsset extends AssetBundle
{
    public $sourcePath = '@npm/stupid-table-plugin';
    public $js = [
        'stupidtable.min.js',
    ];
    public $depends = [
        JqueryAsset::class,
    ];
}
