import 'app_language.dart';

/// 应用级文案（导航、设置、工具页外壳）。
///
/// 工具自己的文案放在各自目录的 `<tool>_lang.dart` 里，见 `lib/ui/tools/<tool>/`。
abstract class AppStrings {
  const AppStrings();

  /// 当前语言对应的文案表。
  static AppStrings of(AppLanguage language) => switch (language) {
    AppLanguage.zhHans => const _ZhHansStrings(),
    AppLanguage.zhHant => const _ZhHantStrings(),
    AppLanguage.en => const _EnStrings(),
    AppLanguage.ja => const _JaStrings(),
    AppLanguage.es => const _EsStrings(),
  };

  String get appTitle;
  String get navCalculator;
  String get navTools;
  String get navSettings;

  String get toolsTitle;
  String get toolsOffline;

  /// 「12 个应用」这类计数文案，[count] 为工具数量。
  String toolsCount(int count);

  /// 工具页「置顶」分区的小标题。
  /// 工具页搜索框的提示语。
  String get toolsSearchHint;

  /// 工具页搜索时的分区标题。
  String get toolsSearchResults;

  /// 搜索没有结果时的标题与说明。
  String get toolsSearchEmpty;
  String get toolsSearchEmptyHint;

  /// 搜索框里清空按钮的提示。
  String get toolsSearchClear;

  String get toolsPinned;

  /// 工具页「其他工具」分区的小标题。
  String get toolsOthers;

  /// 卡片右上角图钉的提示：置顶。
  String get toolPin;

  /// 卡片右上角图钉的提示：取消置顶。
  String get toolUnpin;

  /// 置顶已满时的提示，`{0}` 是当前上限。
  String toolPinLimit(int limit);

  /// 设置页「置顶工具」卡片标题。
  String get settingsPinned;

  /// 设置页「置顶数量」下拉框标签。
  String get settingsPinnedLimit;

  /// 设置页置顶卡片的说明。
  String get settingsPinnedHint;

  /// 「已置顶 2 / 3」。
  String pinnedCount(int count, int limit);

  String get settingsTitle;
  String get settingsSubtitle;
  String get settingsAppearance;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get settingsLanguage;
  String get settingsLanguageHint;
  String get settingsConversion;
  String get settingsConversionHint;
  String get settingsConvertSystem;
  String get settingsConvertTab;
  String get settingsConvertUnit;
  String get settingsEngineering;
  String get settingsEngineeringHint;
  String get settingsDefaultTab;
  String get systemMetric;
  String get systemImperial;
  String get systemChinese;
  String get settingsAbout;
  String get aboutDescription;
  String get aboutVersion;
  String get aboutRepo;
  String get aboutRepoAction;
  String get aboutLinkCopied;
  String get settingsFootnote;
}

class _ZhHansStrings extends AppStrings {
  const _ZhHansStrings();

  @override
  String get appTitle => '工程助手';
  @override
  String get navCalculator => '计算';
  @override
  String get navTools => '工具';
  @override
  String get navSettings => '设置';
  @override
  String get toolsTitle => '工具';
  @override
  String get toolsOffline => '全部内置，离线可用';
  @override
  String toolsCount(int count) => '$count 个应用';
  @override
  String get toolsSearchHint => '搜索工具名称或卖点';
  @override
  String get toolsSearchResults => '搜索结果';
  @override
  String get toolsSearchEmpty => '没有匹配的工具';
  @override
  String get toolsSearchEmptyHint => '换个关键词试试，或者点右边的叉清空搜索框。';
  @override
  String get toolsSearchClear => '清空搜索';
  @override
  String get toolsPinned => '置顶工具';
  @override
  String get toolsOthers => '其他工具';
  @override
  String get toolPin => '置顶';
  @override
  String get toolUnpin => '取消置顶';
  @override
  String toolPinLimit(int limit) => '最多只能置顶 $limit 个工具，可在设置里调整';
  @override
  String get settingsPinned => '置顶工具';
  @override
  String get settingsPinnedLimit => '置顶数量';
  @override
  String get settingsPinnedHint => '点工具卡片右上角的图钉即可置顶或取消，置顶的工具排在工具页最前面。';
  @override
  String pinnedCount(int count, int limit) => '已置顶 $count / $limit';
  @override
  String get settingsTitle => '设置';
  @override
  String get settingsSubtitle => '外观与语言，只保存在本机';
  @override
  String get settingsAppearance => '外观';
  @override
  String get themeSystem => '跟随系统';
  @override
  String get themeLight => '浅色';
  @override
  String get themeDark => '深色';
  @override
  String get settingsLanguage => '语言';
  @override
  String get settingsLanguageHint => '界面文案立即切换；工具内部文案正在逐步补齐。';
  @override
  String get settingsConversion => '单位换算默认值';
  @override
  String get settingsConversionHint => '每个换算工具各记一套：打开时的计量体系，以及结果默认选中的标签页。';
  @override
  String get settingsConvertSystem => '默认体系';
  @override
  String get settingsConvertUnit => '默认单位';
  @override
  String get settingsConvertTab => '结果 tab';
  @override
  String get settingsEngineering => '工程计算默认值';
  @override
  String get settingsEngineeringHint => '打开工具时默认展示哪个标签页；每个工具各记一套。';
  @override
  String get settingsDefaultTab => '默认标签页';
  @override
  String get systemMetric => '公制';
  @override
  String get systemImperial => '英制';
  @override
  String get systemChinese => '市制';
  @override
  String get settingsAbout => '关于';
  @override
  String get aboutDescription => '表达式求值 + 内置单位换算工具，全部离线可用。';
  @override
  String get aboutVersion => '版本';
  @override
  String get aboutRepo => '开源地址';
  @override
  String get aboutRepoAction => '复制链接';
  @override
  String get aboutLinkCopied => '仓库链接已复制';
  @override
  String get settingsFootnote => '设置保存在本机，不会上传。';
}

class _ZhHantStrings extends AppStrings {
  const _ZhHantStrings();

  @override
  String get appTitle => '工程助手';
  @override
  String get navCalculator => '計算';
  @override
  String get navTools => '工具';
  @override
  String get navSettings => '設定';
  @override
  String get toolsTitle => '工具';
  @override
  String get toolsOffline => '全部內建，離線可用';
  @override
  String toolsCount(int count) => '$count 個應用';
  @override
  String get toolsSearchHint => '搜尋工具名稱或特色';
  @override
  String get toolsSearchResults => '搜尋結果';
  @override
  String get toolsSearchEmpty => '沒有符合的工具';
  @override
  String get toolsSearchEmptyHint => '換個關鍵字試試，或點右邊的叉清空搜尋框。';
  @override
  String get toolsSearchClear => '清空搜尋';
  @override
  String get toolsPinned => '置頂工具';
  @override
  String get toolsOthers => '其他工具';
  @override
  String get toolPin => '置頂';
  @override
  String get toolUnpin => '取消置頂';
  @override
  String toolPinLimit(int limit) => '最多只能置頂 $limit 個工具，可在設定裡調整';
  @override
  String get settingsPinned => '置頂工具';
  @override
  String get settingsPinnedLimit => '置頂數量';
  @override
  String get settingsPinnedHint => '點工具卡片右上角的圖釘即可置頂或取消，置頂的工具排在工具頁最前面。';
  @override
  String pinnedCount(int count, int limit) => '已置頂 $count / $limit';
  @override
  String get settingsTitle => '設定';
  @override
  String get settingsSubtitle => '外觀與語言，只儲存在本機';
  @override
  String get settingsAppearance => '外觀';
  @override
  String get themeSystem => '跟隨系統';
  @override
  String get themeLight => '淺色';
  @override
  String get themeDark => '深色';
  @override
  String get settingsLanguage => '語言';
  @override
  String get settingsLanguageHint => '介面文字立即切換；工具內部文字正在逐步補齊。';
  @override
  String get settingsConversion => '單位換算預設值';
  @override
  String get settingsConversionHint => '六個換算工具各記一套：開啟時的計量體系，以及結果預設選中的分頁。';
  @override
  String get settingsConvertSystem => '預設體系';
  @override
  String get settingsConvertUnit => '預設單位';
  @override
  String get settingsConvertTab => '結果分頁';
  @override
  String get settingsEngineering => '工程計算預設值';
  @override
  String get settingsEngineeringHint => '開啟工具時預設展示哪個分頁；每個工具各記一套。';
  @override
  String get settingsDefaultTab => '預設分頁';
  @override
  String get systemMetric => '公制';
  @override
  String get systemImperial => '英制';
  @override
  String get systemChinese => '市制';
  @override
  String get settingsAbout => '關於';
  @override
  String get aboutDescription => '表達式求值 + 內建單位換算工具，全部離線可用。';
  @override
  String get aboutVersion => '版本';
  @override
  String get aboutRepo => '開源位址';
  @override
  String get aboutRepoAction => '複製連結';
  @override
  String get aboutLinkCopied => '已複製倉庫連結';
  @override
  String get settingsFootnote => '設定儲存在本機，不會上傳。';
}

class _EnStrings extends AppStrings {
  const _EnStrings();

  @override
  String get appTitle => 'Engineering Assistant';
  @override
  String get navCalculator => 'Calc';
  @override
  String get navTools => 'Tools';
  @override
  String get navSettings => 'Settings';
  @override
  String get toolsTitle => 'Tools';
  @override
  String get toolsOffline => 'All built in, works offline';
  @override
  String toolsCount(int count) => '$count apps';
  @override
  String get toolsSearchHint => 'Search by name or description';
  @override
  String get toolsSearchResults => 'Results';
  @override
  String get toolsSearchEmpty => 'No matching tools';
  @override
  String get toolsSearchEmptyHint =>
      'Try another keyword, or tap the cross to clear the search.';
  @override
  String get toolsSearchClear => 'Clear search';
  @override
  String get toolsPinned => 'Pinned';
  @override
  String get toolsOthers => 'More tools';
  @override
  String get toolPin => 'Pin to top';
  @override
  String get toolUnpin => 'Unpin';
  @override
  String toolPinLimit(int limit) =>
      'You can pin up to $limit tools. Change the limit in Settings.';
  @override
  String get settingsPinned => 'Pinned tools';
  @override
  String get settingsPinnedLimit => 'How many can be pinned';
  @override
  String get settingsPinnedHint =>
      'Tap the pin at the top-right of a card to pin or unpin it. '
      'Pinned tools stay at the top of the Tools page.';
  @override
  String pinnedCount(int count, int limit) => 'Pinned $count / $limit';
  @override
  String get settingsTitle => 'Settings';
  @override
  String get settingsSubtitle =>
      'Appearance and language, stored on this device';
  @override
  String get settingsAppearance => 'Appearance';
  @override
  String get themeSystem => 'System';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
  @override
  String get settingsLanguage => 'Language';
  @override
  String get settingsLanguageHint =>
      'UI text switches immediately; tool contents are being translated.';
  @override
  String get settingsConversion => 'Unit converter defaults';
  @override
  String get settingsConversionHint =>
      'Stored per tool: the unit system it opens with and the result tab it shows first.';
  @override
  String get settingsConvertSystem => 'Default system';
  @override
  String get settingsConvertUnit => 'Default unit';
  @override
  String get settingsConvertTab => 'Result tab';
  @override
  String get settingsEngineering => 'Engineering defaults';
  @override
  String get settingsEngineeringHint =>
      'Which tab a tool opens on. Stored per tool.';
  @override
  String get settingsDefaultTab => 'Default tab';
  @override
  String get systemMetric => 'Metric';
  @override
  String get systemImperial => 'Imperial';
  @override
  String get systemChinese => 'Chinese';
  @override
  String get settingsAbout => 'About';
  @override
  String get aboutDescription =>
      'Expression evaluator and built-in unit conversion tools, all offline.';
  @override
  String get aboutVersion => 'Version';
  @override
  String get aboutRepo => 'Repository';
  @override
  String get aboutRepoAction => 'Copy link';
  @override
  String get aboutLinkCopied => 'Repository link copied';
  @override
  String get settingsFootnote => 'Settings stay on this device.';
}

class _JaStrings extends AppStrings {
  const _JaStrings();

  @override
  String get appTitle => 'Engineering Assistant';
  @override
  String get navCalculator => '計算';
  @override
  String get navTools => 'ツール';
  @override
  String get navSettings => '設定';
  @override
  String get toolsTitle => 'ツール';
  @override
  String get toolsOffline => 'すべて内蔵、オフラインで動作';
  @override
  String toolsCount(int count) => '$count 個のアプリ';
  @override
  String get toolsSearchHint => 'ツール名や説明で検索';
  @override
  String get toolsSearchResults => '検索結果';
  @override
  String get toolsSearchEmpty => '該当するツールがありません';
  @override
  String get toolsSearchEmptyHint => '別のキーワードを試すか、右の × で検索をクリアしてください。';
  @override
  String get toolsSearchClear => '検索をクリア';
  @override
  String get toolsPinned => 'ピン留め';
  @override
  String get toolsOthers => 'その他のツール';
  @override
  String get toolPin => 'ピン留めする';
  @override
  String get toolUnpin => 'ピン留めを解除';
  @override
  String toolPinLimit(int limit) => 'ピン留めできるのは最大 $limit 個です。設定で変更できます。';
  @override
  String get settingsPinned => 'ピン留めしたツール';
  @override
  String get settingsPinnedLimit => 'ピン留めの上限';
  @override
  String get settingsPinnedHint =>
      'カード右上のピンを押すとピン留め / 解除できます。'
      'ピン留めしたツールはツールページの先頭に並びます。';
  @override
  String pinnedCount(int count, int limit) => 'ピン留め $count / $limit';
  @override
  String get settingsTitle => '設定';
  @override
  String get settingsSubtitle => '外観と言語、この端末にのみ保存';
  @override
  String get settingsAppearance => '外観';
  @override
  String get themeSystem => 'システム';
  @override
  String get themeLight => 'ライト';
  @override
  String get themeDark => 'ダーク';
  @override
  String get settingsLanguage => '言語';
  @override
  String get settingsLanguageHint => '画面の文言はすぐに切り替わります。ツール内の文言は順次対応中です。';
  @override
  String get settingsConversion => '単位換算の既定値';
  @override
  String get settingsConversionHint => '6 つの換算ツールごとに、開いたときの単位系と結果タブを記憶します。';
  @override
  String get settingsConvertSystem => '既定の単位系';
  @override
  String get settingsConvertUnit => '既定の単位';
  @override
  String get settingsConvertTab => '結果タブ';
  @override
  String get settingsEngineering => '工学計算の既定値';
  @override
  String get settingsEngineeringHint => 'ツールを開いたときに表示するタブを記憶します（ツールごと）。';
  @override
  String get settingsDefaultTab => '既定のタブ';
  @override
  String get systemMetric => 'メートル法';
  @override
  String get systemImperial => 'ヤード・ポンド法';
  @override
  String get systemChinese => '中国の市制';
  @override
  String get settingsAbout => 'このアプリについて';
  @override
  String get aboutDescription => '数式評価と内蔵の単位換算ツール。すべてオフラインで使えます。';
  @override
  String get aboutVersion => 'バージョン';
  @override
  String get aboutRepo => 'リポジトリ';
  @override
  String get aboutRepoAction => 'リンクをコピー';
  @override
  String get aboutLinkCopied => 'リポジトリのリンクをコピーしました';
  @override
  String get settingsFootnote => '設定はこの端末にのみ保存されます。';
}

class _EsStrings extends AppStrings {
  const _EsStrings();

  @override
  String get appTitle => 'Engineering Assistant';
  @override
  String get navCalculator => 'Cálculo';
  @override
  String get navTools => 'Herramientas';
  @override
  String get navSettings => 'Ajustes';
  @override
  String get toolsTitle => 'Herramientas';
  @override
  String get toolsOffline => 'Todo integrado, funciona sin conexión';
  @override
  String toolsCount(int count) => '$count aplicaciones';
  @override
  String get toolsSearchHint => 'Buscar por nombre o descripción';
  @override
  String get toolsSearchResults => 'Resultados';
  @override
  String get toolsSearchEmpty => 'Ninguna herramienta coincide';
  @override
  String get toolsSearchEmptyHint =>
      'Prueba con otra palabra o toca la cruz para limpiar la búsqueda.';
  @override
  String get toolsSearchClear => 'Limpiar búsqueda';
  @override
  String get toolsPinned => 'Fijados';
  @override
  String get toolsOthers => 'Más herramientas';
  @override
  String get toolPin => 'Fijar arriba';
  @override
  String get toolUnpin => 'Quitar de fijados';
  @override
  String toolPinLimit(int limit) =>
      'Solo puedes fijar $limit herramientas. Cámbialo en Ajustes.';
  @override
  String get settingsPinned => 'Herramientas fijadas';
  @override
  String get settingsPinnedLimit => 'Cuántas se pueden fijar';
  @override
  String get settingsPinnedHint =>
      'Toca el alfiler de la esquina superior derecha de una tarjeta para '
      'fijarla o quitarla. Las fijadas se quedan arriba en Herramientas.';
  @override
  String pinnedCount(int count, int limit) => 'Fijados $count / $limit';
  @override
  String get settingsTitle => 'Ajustes';
  @override
  String get settingsSubtitle =>
      'Apariencia e idioma, guardados en este dispositivo';
  @override
  String get settingsAppearance => 'Apariencia';
  @override
  String get themeSystem => 'Sistema';
  @override
  String get themeLight => 'Claro';
  @override
  String get themeDark => 'Oscuro';
  @override
  String get settingsLanguage => 'Idioma';
  @override
  String get settingsLanguageHint =>
      'Los textos de la interfaz cambian al instante; el contenido de las herramientas se está traduciendo.';
  @override
  String get settingsConversion => 'Valores de conversión';
  @override
  String get settingsConversionHint =>
      'Se guarda por herramienta: el sistema con el que abre y la pestaña de resultados.';
  @override
  String get settingsConvertSystem => 'Sistema por defecto';
  @override
  String get settingsConvertUnit => 'Unidad predeterminada';
  @override
  String get settingsConvertTab => 'Pestaña de resultados';
  @override
  String get settingsEngineering => 'Valores de obra';
  @override
  String get settingsEngineeringHint =>
      'Pestaña con la que se abre cada herramienta.';
  @override
  String get settingsDefaultTab => 'Pestaña inicial';
  @override
  String get systemMetric => 'Métrico';
  @override
  String get systemImperial => 'Imperial';
  @override
  String get systemChinese => 'Chino';
  @override
  String get settingsAbout => 'Acerca de';
  @override
  String get aboutDescription =>
      'Evaluador de expresiones y herramientas de conversión de unidades, todo sin conexión.';
  @override
  String get aboutVersion => 'Versión';
  @override
  String get aboutRepo => 'Repositorio';
  @override
  String get aboutRepoAction => 'Copiar enlace';
  @override
  String get aboutLinkCopied => 'Enlace del repositorio copiado';
  @override
  String get settingsFootnote => 'Los ajustes se quedan en este dispositivo.';
}
