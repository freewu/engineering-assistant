/* 工程助手官网的交互：语言、主题、工具网格与大图浮层。
 *
 * 站点支持三种语言（简体 / 繁體 / English），截图的界面语言跟着站点走：
 * 每种语言一套 docs/shots/<语言>/ 截图，由 `just site-shots` 生成
 * （见 tool/screenshot.sh 与 tool/screenshot.sh --check）。
 */
(() => {
  'use strict';

  const SITE_LANGS = ['zh-Hans', 'zh-Hant', 'en'];
  const FALLBACK_LANG = 'zh-Hans';
  const STORAGE_LANG = 'ea.site.lang';
  const STORAGE_THEME = 'ea.site.theme';
  const SHOT_DIR = 'shots';

  const STRINGS = {
    'zh-Hans': {
      'meta.title': '工程助手 · 工程人员的计算工具集',
      'meta.desc':
        '工程助手：表达式计算、八个单位换算与十一项工程量计算，全部内置、离线可用。Web / Windows / Android 同一套界面，支持深色浅色与多语言。',
      'a11y.skip': '跳到主要内容',
      'app.name': '工程助手',
      'app.sub': '工程人员的计算工具集',
      'nav.features': '功能',
      'nav.tools': '工具',
      'nav.screens': '截图',
      'nav.platforms': '平台',
      'nav.repo': '源码',
      'hero.eyebrow': 'Flutter · Web / Windows / Android',
      'hero.title': '工程计算，随手就来',
      'hero.lead':
        '表达式计算、八个单位换算与十一项工程量计算，全部内置、离线可用；深色浅色随心切换，Web、Windows、Android 是同一套界面。',
      'hero.ctaPrimary': '下载安装',
      'hero.ctaSecondary': '浏览源码',
      'hero.chip1': '离线可用',
      'hero.chip2': '深色 · 浅色',
      'hero.chip3': '五种语言',
      'hero.chip4': '免费开源',
      'hero.shotCaption': '实机截图 · 简体中文',
      'features.title': '功能',
      'features.lead': '一个 App 覆盖从表达式到工程量的全部日常计算。',
      'features.calc.title': '表达式计算',
      'features.calc.body':
        '自研词法与递归下降解析，支持隐式乘法、幂运算右结合与 48 个内置函数；定积分、数值求导、求和连乘都能直接算。',
      'features.convert.title': '单位换算',
      'features.convert.body':
        '长度、面积、容量、重量、温度、热量、压力、速度八个工具，按公制 / 英制 / 市制分体系，结果一屏列全，点一下即复制。',
      'features.quantity.title': '工程量计算',
      'features.quantity.body':
        '材料用量、建筑面积、混凝土构件、土石方、钢筋、砌筑、模板、屋面及防水、保温隔热、装饰装修与油漆涂料，按 GB/T 50854-2024 清单规则算。',
      'features.offline.title': '离线可用',
      'features.offline.body':
        '引擎、字体、图标全部内置，运行时不请求网络，工地上没信号也能照常用。',
      'features.theme.title': '深色 · 浅色',
      'features.theme.body':
        '默认深色科学计算器配色，浅色下同一套色相压暗；可以跟随系统，也可以手动固定。',
      'features.memory.title': '记得你填过什么',
      'features.memory.body':
        '每个工具都记住上次的数字与选项，输入停一下就存盘；常用工具可以置顶到最前面。',
      'tools.title': '十九个工具，一个入口',
      'tools.lead':
        '工具页里点开即用。下面是每个工具的实机截图，点开可以看大图；切换站点语言，截图里的界面也跟着换。',
      'tools.count': '8 个单位换算 · 11 个工程量计算',
      'screens.title': '界面截图',
      'screens.lead': '工具页与设置页，截图与站点语言一致。',
      'screens.calculator': '计算器',
      'screens.tools': '工具页',
      'screens.settings': '设置页',
      'platforms.title': '平台',
      'platforms.lead': '同一套代码，三个平台。',
      'platforms.web.body':
        '浏览器直接打开。构建产物自包含（CanvasKit 与字体都在本地），拷到内网服务器即可离线使用。',
      'platforms.windows.body':
        '原生桌面窗口，物理键盘输入更快，适合和图纸一起开着用。',
      'platforms.android.body':
        '手机、平板随身带，APK 直接安装，工地上随手算。',
      'footer.built': '用 Flutter 构建',
      'footer.shots': '截图由 just site-shots 生成，与站点语言一致。',
      'lightbox.close': '关闭',
      'theme.toLight': '切换到浅色',
      'theme.toDark': '切换到深色',
    },

    'zh-Hant': {
      'meta.title': '工程助手 · 工程人員的計算工具集',
      'meta.desc':
        '工程助手：表達式計算、八個單位換算與十一項工程量計算，全部內建、離線可用。Web / Windows / Android 同一套介面，支援深色淺色與多語言。',
      'a11y.skip': '跳到主要內容',
      'app.name': '工程助手',
      'app.sub': '工程人員的計算工具集',
      'nav.features': '功能',
      'nav.tools': '工具',
      'nav.screens': '截圖',
      'nav.platforms': '平台',
      'nav.repo': '原始碼',
      'hero.eyebrow': 'Flutter · Web / Windows / Android',
      'hero.title': '工程計算，隨手就來',
      'hero.lead':
        '表達式計算、八個單位換算與十一項工程量計算，全部內建、離線可用；深色淺色隨心切換，Web、Windows、Android 是同一套介面。',
      'hero.ctaPrimary': '下載安裝',
      'hero.ctaSecondary': '瀏覽原始碼',
      'hero.chip1': '離線可用',
      'hero.chip2': '深色 · 淺色',
      'hero.chip3': '五種語言',
      'hero.chip4': '免費開源',
      'hero.shotCaption': '實機截圖 · 繁體中文',
      'features.title': '功能',
      'features.lead': '一個 App 涵蓋從表達式到工程量的全部日常計算。',
      'features.calc.title': '表達式計算',
      'features.calc.body':
        '自研詞法與遞迴下降解析，支援隱式乘法、冪運算右結合與 48 個內建函式；定積分、數值微分、求和連乘都能直接算。',
      'features.convert.title': '單位換算',
      'features.convert.body':
        '長度、面積、容量、重量、溫度、熱量、壓力、速度八個工具，按公制 / 英制 / 市制分體系，結果一螢幕列全，點一下即複製。',
      'features.quantity.title': '工程量計算',
      'features.quantity.body':
        '材料用量、建築面積、混凝土構件、土石方、鋼筋、砌築、模板、屋面及防水、隔熱保溫、裝飾裝修與油漆塗料，按 GB/T 50854-2024 清單規則計算。',
      'features.offline.title': '離線可用',
      'features.offline.body':
        '引擎、字型、圖示全部內建，執行時不請求網路，工地沒訊號也能照樣用。',
      'features.theme.title': '深色 · 淺色',
      'features.theme.body':
        '預設深色科學計算機配色，淺色下同一套色相壓暗；可以跟隨系統，也可以手動固定。',
      'features.memory.title': '記得你填過什麼',
      'features.memory.body':
        '每個工具都記住上次的數字與選項，輸入停一下就存檔；常用工具可以置頂到最前面。',
      'tools.title': '十九個工具，一個入口',
      'tools.lead':
        '工具頁裡點開即用。下面是每個工具的實機截圖，點開可以看大圖；切換站台語言，截圖裡的介面也跟著換。',
      'tools.count': '8 個單位換算 · 11 個工程量計算',
      'screens.title': '介面截圖',
      'screens.lead': '工具頁與設定頁，截圖與站台語言一致。',
      'screens.calculator': '計算機',
      'screens.tools': '工具頁',
      'screens.settings': '設定頁',
      'platforms.title': '平台',
      'platforms.lead': '同一套程式，三個平台。',
      'platforms.web.body':
        '瀏覽器直接開啟。建置產物自包含（CanvasKit 與字型都在本機），拷到內網伺服器即可離線使用。',
      'platforms.windows.body':
        '原生桌面視窗，實體鍵盤輸入更快，適合和圖說一起開著用。',
      'platforms.android.body':
        '手機、平板隨身帶，APK 直接安裝，工地隨手算。',
      'footer.built': '以 Flutter 打造',
      'footer.shots': '截圖由 just site-shots 產生，與站台語言一致。',
      'lightbox.close': '關閉',
      'theme.toLight': '切換到淺色',
      'theme.toDark': '切換到深色',
    },

    en: {
      'meta.title': 'Engineering Assistant · a calculator kit for engineers',
      'meta.desc':
        'Engineering Assistant: expression calculator, eight unit converters and eleven quantity take-off tools — all built in and fully offline. One interface for Web, Windows and Android, with dark/light themes and five languages.',
      'a11y.skip': 'Skip to main content',
      'app.name': 'Engineering Assistant',
      'app.sub': 'A calculator kit for engineers',
      'nav.features': 'Features',
      'nav.tools': 'Tools',
      'nav.screens': 'Screenshots',
      'nav.platforms': 'Platforms',
      'nav.repo': 'Source',
      'hero.eyebrow': 'Flutter · Web / Windows / Android',
      'hero.title': 'Engineering math, right at hand',
      'hero.lead':
        'Expression calculator, eight unit converters and eleven quantity take-off tools — all built in and fully offline. Dark and light themes, one interface for Web, Windows and Android.',
      'hero.ctaPrimary': 'Download',
      'hero.ctaSecondary': 'View source',
      'hero.chip1': 'Works offline',
      'hero.chip2': 'Dark & light',
      'hero.chip3': 'Five languages',
      'hero.chip4': 'Open source',
      'hero.shotCaption': 'Live screenshot · English',
      'features.title': 'Features',
      'features.lead':
        'One app for everything from a quick expression to a full take-off.',
      'features.calc.title': 'Expression calculator',
      'features.calc.body':
        'A hand-written lexer and recursive-descent parser with implicit multiplication, right-associative powers and 48 built-in functions, plus definite integrals, numerical derivatives, sums and products.',
      'features.convert.title': 'Unit conversion',
      'features.convert.body':
        'Length, area, volume, weight, temperature, energy, pressure and speed — grouped by metric, imperial and Chinese units, every result on one screen, tap to copy.',
      'features.quantity.title': 'Quantity take-off',
      'features.quantity.body':
        'Materials, floor area, concrete members, earthwork, reinforcement, masonry, formwork, roofing and waterproofing, insulation, finishes and paints — following the GB/T 50854-2024 measurement rules.',
      'features.offline.title': 'Works offline',
      'features.offline.body':
        'Engine, fonts and icons are all bundled; nothing is fetched at runtime, so it still works where there is no signal.',
      'features.theme.title': 'Dark & light',
      'features.theme.body':
        'A dark scientific-calculator skin by default, with the same hues darkened for light mode; follow the system or pin your choice.',
      'features.memory.title': 'Remembers your input',
      'features.memory.body':
        'Every tool keeps its last numbers and options, saved a moment after you stop typing; pin the tools you use most to the top.',
      'tools.title': 'Nineteen tools, one entry',
      'tools.lead':
        'Open a tool and it is ready. Below is a live screenshot of each one — click for a larger view. Switch the site language and the interface follows.',
      'tools.count': '8 unit converters · 11 quantity tools',
      'screens.title': 'Screenshots',
      'screens.lead':
        'The tools page and settings — screenshots match the site language.',
      'screens.calculator': 'Calculator',
      'screens.tools': 'Tools page',
      'screens.settings': 'Settings',
      'platforms.title': 'Platforms',
      'platforms.lead': 'One codebase, three platforms.',
      'platforms.web.body':
        'Runs right in the browser. The build is self-contained (CanvasKit and fonts are local), so it also works offline on an intranet server.',
      'platforms.windows.body':
        'A native desktop window with a real keyboard — handy next to your drawings.',
      'platforms.android.body':
        'Phone and tablet, installed from the APK, ready on site.',
      'footer.built': 'Built with Flutter',
      'footer.shots':
        'Screenshots generated by just site-shots, matching the site language.',
      'lightbox.close': 'Close',
      'theme.toLight': 'Switch to light',
      'theme.toDark': 'Switch to dark',
    },
  };

  /* 工具列表：id 与 App 的 ToolInfo.id 一致（深链 ?tool=<id>），
   * 名称与卖点取自各工具的 <tool>_lang.dart。 */
  const TOOLS = [
    {
      id: 'material',
      icon: '🧱',
      name: { 'zh-Hans': '材料用量', 'zh-Hant': '材料用量', en: 'Materials' },
      tag: {
        'zh-Hans': '砖块水泥砂子，一算就有',
        'zh-Hant': '磚塊水泥砂子，一算就有',
        en: 'Bricks, concrete, cement, sand',
      },
    },
    {
      id: 'building_area',
      icon: '🏢',
      name: { 'zh-Hans': '建筑面积', 'zh-Hant': '建築面積', en: 'Floor area' },
      tag: {
        'zh-Hans': '单层多层阳台，分项算',
        'zh-Hant': '單層多層陽台，分項算',
        en: 'Storeys, balconies, canopies',
      },
    },
    {
      id: 'concrete',
      icon: '🏗️',
      name: { 'zh-Hans': '混凝土构件', 'zh-Hant': '混凝土構件', en: 'Concrete' },
      tag: {
        'zh-Hans': '柱梁板墙楼梯，按体积算',
        'zh-Hant': '柱梁板牆樓梯，按體積算',
        en: 'Columns, beams, slabs, walls, stairs',
      },
    },
    {
      id: 'earthwork',
      icon: '🚜',
      name: { 'zh-Hans': '土石方工程', 'zh-Hant': '土石方工程', en: 'Earthwork' },
      tag: {
        'zh-Hans': '场地平整、开挖、管沟土方',
        'zh-Hant': '場地平整、開挖、管溝土方',
        en: 'Grading, excavation, pipe trenches',
      },
    },
    {
      id: 'rebar',
      icon: '🔩',
      name: { 'zh-Hans': '钢筋工程', 'zh-Hant': '鋼筋工程', en: 'Reinforcement' },
      tag: {
        'zh-Hans': '直钢筋、箍筋、弯起钢筋与速查表',
        'zh-Hant': '直鋼筋、箍筋、彎起鋼筋與速查表',
        en: 'Bars, stirrups, bent-up bars, table',
      },
    },
    {
      id: 'masonry',
      icon: '🏛️',
      name: { 'zh-Hans': '砌筑工程', 'zh-Hant': '砌築工程', en: 'Masonry' },
      tag: {
        'zh-Hans': '砖墙、砖基础与特殊墙体',
        'zh-Hant': '磚牆、磚基礎與特殊牆體',
        en: 'Brick walls, footings and special walls',
      },
    },
    {
      id: 'formwork',
      icon: '🪵',
      name: { 'zh-Hans': '模板工程', 'zh-Hant': '模板工程', en: 'Formwork' },
      tag: {
        'zh-Hans': '柱、梁、墙、楼梯的模板接触面积',
        'zh-Hant': '柱、樑、牆、樓梯的模板接觸面積',
        en: 'Contact area for columns, beams, walls, stairs',
      },
    },
    {
      id: 'roof',
      icon: '🏠',
      name: {
        'zh-Hans': '屋面及防水',
        'zh-Hant': '屋面及防水',
        en: 'Roof & waterproofing',
      },
      tag: {
        'zh-Hans': '平屋面、坡屋面、楼地面与墙基防水',
        'zh-Hant': '平屋面、斜屋面、樓地面與牆基防水',
        en: 'Flat and pitched roofs, floors, wall bases',
      },
    },
    {
      id: 'insulation',
      icon: '🧊',
      name: { 'zh-Hans': '保温隔热', 'zh-Hant': '隔熱保溫', en: 'Insulation' },
      tag: {
        'zh-Hans': '屋面、墙面与柱的保温面积与体积',
        'zh-Hant': '屋面、牆面與柱的保溫面積與體積',
        en: 'Roof, wall and column areas and volumes',
      },
    },
    {
      id: 'decoration',
      icon: '🎨',
      name: { 'zh-Hans': '装饰装修', 'zh-Hant': '裝飾裝修', en: 'Finishes' },
      tag: {
        'zh-Hans': '墙面、天棚与楼地面的装饰面积',
        'zh-Hant': '牆面、天棚與樓地面的裝飾面積',
        en: 'Wall, ceiling and floor finish areas',
      },
    },
    {
      id: 'paint',
      icon: '🖌️',
      name: { 'zh-Hans': '油漆涂料', 'zh-Hant': '油漆塗料', en: 'Paints' },
      tag: {
        'zh-Hans': '墙面、天棚与门窗的涂刷面积与用量',
        'zh-Hant': '牆面、天棚與門窗的塗刷面積與用量',
        en: 'Paint areas and coating quantities',
      },
    },
    {
      id: 'distance',
      icon: '📏',
      name: { 'zh-Hans': '长度换算', 'zh-Hant': '長度換算', en: 'Length' },
      tag: {
        'zh-Hans': '公制英制，一屏换算',
        'zh-Hant': '公制英制，一螢幕換算',
        en: 'Metric and imperial, one screen',
      },
    },
    {
      id: 'area',
      icon: '📐',
      name: { 'zh-Hans': '面积换算', 'zh-Hant': '面積換算', en: 'Area' },
      tag: {
        'zh-Hans': '平方米到亩，一键换算',
        'zh-Hant': '平方公尺到畝，一鍵換算',
        en: 'Square metres to mu, one tap',
      },
    },
    {
      id: 'volume',
      icon: '🥛',
      name: { 'zh-Hans': '容量换算', 'zh-Hant': '容量換算', en: 'Volume' },
      tag: {
        'zh-Hans': '升与加仑，厨房能用',
        'zh-Hant': '公升與加侖，廚房能用',
        en: 'Litres and gallons, kitchen ready',
      },
    },
    {
      id: 'weight',
      icon: '⚖️',
      name: { 'zh-Hans': '重量换算', 'zh-Hant': '重量換算', en: 'Weight' },
      tag: {
        'zh-Hans': '斤两磅，随手换',
        'zh-Hant': '斤兩磅，隨手換',
        en: 'Jin, liang and pounds on the fly',
      },
    },
    {
      id: 'temperature',
      icon: '🌡️',
      name: { 'zh-Hans': '温度换算', 'zh-Hant': '溫度換算', en: 'Temperature' },
      tag: {
        'zh-Hans': '摄氏华氏，连同体感',
        'zh-Hant': '攝氏華氏，連同體感',
        en: 'Celsius, Fahrenheit and how it feels',
      },
    },
    {
      id: 'energy',
      icon: '🔥',
      name: { 'zh-Hans': '热量换算', 'zh-Hant': '熱量換算', en: 'Energy' },
      tag: {
        'zh-Hans': '瓦时焦耳卡路里',
        'zh-Hant': '瓦時焦耳卡路里',
        en: 'Watt-hours, joules, calories',
      },
    },
    {
      id: 'pressure',
      icon: '🎛️',
      name: { 'zh-Hans': '压力换算', 'zh-Hant': '壓力換算', en: 'Pressure' },
      tag: {
        'zh-Hans': '帕巴托，还有 psi',
        'zh-Hant': '帕巴托，還有 psi',
        en: 'Pascal, bar and psi',
      },
    },
    {
      id: 'speed',
      icon: '🚄',
      name: { 'zh-Hans': '速度换算', 'zh-Hant': '速度換算', en: 'Speed' },
      tag: {
        'zh-Hans': '车速航速，一节就懂',
        'zh-Hant': '車速航速，一節就懂',
        en: 'Road speed, knots and Mach',
      },
    },
  ];

  /* 页面级截图的说明文案 */
  const PAGE_CAPTIONS = {
    calculator: 'screens.calculator',
    tools: 'screens.tools',
    settings: 'screens.settings',
  };

  const html = document.documentElement;
  const toolsGrid = document.getElementById('tools-grid');
  const metaDesc = document.getElementById('meta-desc');
  const metaOgTitle = document.getElementById('meta-og-title');
  const metaOgDesc = document.getElementById('meta-og-desc');
  const metaTheme = document.getElementById('meta-theme');
  const themeToggle = document.getElementById('theme-toggle');
  const themeIcon = document.getElementById('theme-icon');
  const lightbox = document.getElementById('lightbox');
  const lightboxImg = document.getElementById('lightbox-img');
  const lightboxCaption = document.getElementById('lightbox-caption');
  const lightboxClose = document.getElementById('lightbox-close');
  const langButtons = Array.from(document.querySelectorAll('[data-set-lang]'));

  let lang = pickLang(html.dataset.lang);
  let theme = pickTheme();

  function dict() {
    return STRINGS[lang] || STRINGS[FALLBACK_LANG];
  }

  function t(key) {
    const table = dict();
    return table[key] ?? STRINGS[FALLBACK_LANG][key] ?? key;
  }

  function pickLang(initial) {
    const fromUrl = new URLSearchParams(location.search).get('lang');
    if (SITE_LANGS.includes(fromUrl)) return fromUrl;
    let stored = null;
    try {
      stored = localStorage.getItem(STORAGE_LANG);
    } catch (_) {
      /* 隐私模式下 localStorage 可能抛异常，忽略即可 */
    }
    if (SITE_LANGS.includes(stored)) return stored;
    const candidates = navigator.languages || [navigator.language || ''];
    for (const raw of candidates) {
      const tag = String(raw).toLowerCase();
      if (tag.startsWith('zh')) {
        return /hant|tw|hk|mo/.test(tag) ? 'zh-Hant' : 'zh-Hans';
      }
      if (tag.startsWith('en')) return 'en';
    }
    return SITE_LANGS.includes(initial) ? initial : FALLBACK_LANG;
  }

  function pickTheme() {
    const fromUrl = new URLSearchParams(location.search).get('theme');
    if (fromUrl === 'light' || fromUrl === 'dark') return fromUrl;
    try {
      const stored = localStorage.getItem(STORAGE_THEME);
      if (stored === 'light' || stored === 'dark') return stored;
    } catch (_) {
      /* 同上 */
    }
    const prefersLight =
      window.matchMedia && window.matchMedia('(prefers-color-scheme: light)');
    return prefersLight && prefersLight.matches ? 'light' : 'dark';
  }

  function remember(key, value) {
    try {
      localStorage.setItem(key, value);
    } catch (_) {
      /* 存不下也不影响浏览 */
    }
  }

  function shotUrl(id) {
    return `${SHOT_DIR}/${lang}/${id}.png`;
  }

  function captionFor(id) {
    if (PAGE_CAPTIONS[id]) return t(PAGE_CAPTIONS[id]);
    const tool = TOOLS.find((item) => item.id === id);
    return tool ? tool.name[lang] || tool.name[FALLBACK_LANG] : id;
  }

  let currentShot = null;

  /* 切换界面语言：文案、标题、截图、工具网格一起换 */
  function applyLang(next) {
    if (SITE_LANGS.includes(next)) lang = next;
    html.lang = lang;
    html.dataset.lang = lang;

    document.querySelectorAll('[data-i18n]').forEach((el) => {
      el.textContent = t(el.dataset.i18n);
    });
    document.querySelectorAll('[data-i18n-html]').forEach((el) => {
      el.innerHTML = t(el.dataset.i18nHtml);
    });
    document.querySelectorAll('[data-i18n-title]').forEach((el) => {
      el.title = t(el.dataset.i18nTitle);
    });
    document.querySelectorAll('[data-i18n-aria]').forEach((el) => {
      el.setAttribute('aria-label', t(el.dataset.i18nAria));
    });

    document.title = t('meta.title');
    metaDesc.setAttribute('content', t('meta.desc'));
    metaOgTitle.setAttribute('content', t('meta.title'));
    metaOgDesc.setAttribute('content', t('meta.desc'));

    langButtons.forEach((button) => {
      button.setAttribute(
        'aria-pressed',
        String(button.dataset.setLang === lang)
      );
    });

    renderTools();
    syncShots();
    applyTheme(theme);
  }

  function applyTheme(next) {
    theme = next === 'light' ? 'light' : 'dark';
    html.dataset.theme = theme;
    const dark = theme === 'dark';
    // 图标表示「点了会切到哪」：深色时显示太阳，浅色时显示月亮
    themeIcon.textContent = dark ? '☀️' : '🌙';
    themeToggle.title = dark ? t('theme.toLight') : t('theme.toDark');
    themeToggle.setAttribute(
      'aria-label',
      dark ? t('theme.toLight') : t('theme.toDark')
    );
    metaTheme.setAttribute('content', dark ? '#0A0E14' : '#F4F6FA');
  }

  function renderTools() {
    toolsGrid.innerHTML = TOOLS.map((tool, index) => {
      const name = tool.name[lang] || tool.name[FALLBACK_LANG];
      const tag = tool.tag[lang] || tool.tag[FALLBACK_LANG];
      return `
        <a class="tool" data-shot="${tool.id}" href="${shotUrl(tool.id)}">
          <span class="tool-shot">
            <img data-shot="${tool.id}" src="${shotUrl(tool.id)}"
                 alt="${escapeAttr(name)}" width="1440" height="900" loading="lazy" />
          </span>
          <span class="tool-body">
            <span class="glyph" data-accent="${index % 6}" aria-hidden="true">${
              tool.icon
            }</span>
            <span class="tool-name">
              <strong>${escapeHtml(name)}</strong>
              <span>${escapeHtml(tag)}</span>
            </span>
          </span>
        </a>`;
    }).join('');

  }

  /* 截图语言跟着站点语言走：页面里写死的 <img>/<a> 都换成当前语言那一套 */
  function syncShots() {
    document.querySelectorAll('img[data-shot]').forEach((img) => {
      const id = img.dataset.shot;
      img.src = shotUrl(id);
      img.alt = captionFor(id);
    });
    document.querySelectorAll('a[data-shot]').forEach((link) => {
      const id = link.dataset.shot;
      link.href = shotUrl(id);
      link.title = captionFor(id);
    });
    if (currentShot && !lightbox.hidden) {
      lightboxImg.src = shotUrl(currentShot);
      lightboxImg.alt = captionFor(currentShot);
      lightboxCaption.textContent = captionFor(currentShot);
    }
  }

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
  }

  function escapeAttr(value) {
    return escapeHtml(value).replace(/"/g, '&quot;');
  }

  /* ------------------------------------------------------------ 大图浮层 */

  let lastFocused = null;

  function openLightbox(id) {
    currentShot = id;
    lastFocused = document.activeElement;
    lightboxImg.src = shotUrl(id);
    lightboxImg.alt = captionFor(id);
    lightboxCaption.textContent = captionFor(id);
    lightbox.hidden = false;
    document.body.style.overflow = 'hidden';
    lightboxClose.focus();
  }

  function closeLightbox() {
    if (lightbox.hidden) return;
    currentShot = null;
    lightbox.hidden = true;
    lightboxImg.removeAttribute('src');
    document.body.style.overflow = '';
    if (lastFocused && typeof lastFocused.focus === 'function') {
      lastFocused.focus();
    }
  }

  document.addEventListener('click', (event) => {
    const target = event.target;
    if (!(target instanceof Element)) return;

    const link = target.closest('a[data-shot]');
    if (link) {
      event.preventDefault();
      openLightbox(link.dataset.shot);
      return;
    }

    if (target.closest('#lightbox-close') || target === lightbox) {
      closeLightbox();
    }
  });

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') closeLightbox();
  });

  langButtons.forEach((button) => {
    button.addEventListener('click', () => {
      remember(STORAGE_LANG, button.dataset.setLang);
      applyLang(button.dataset.setLang);
    });
  });

  themeToggle.addEventListener('click', () => {
    const next = theme === 'dark' ? 'light' : 'dark';
    remember(STORAGE_THEME, next);
    applyTheme(next);
  });

  /* 没手动选过配色时跟随系统 */
  if (window.matchMedia) {
    const scheme = window.matchMedia('(prefers-color-scheme: light)');
    const follow = (event) => {
      const fromUrl = new URLSearchParams(location.search).get('theme');
      if (fromUrl === 'light' || fromUrl === 'dark') return;
      try {
        const stored = localStorage.getItem(STORAGE_THEME);
        if (stored === 'light' || stored === 'dark') return;
      } catch (_) {
        /* 隐私模式下读不到，按未选择处理 */
      }
      applyTheme(event.matches ? 'light' : 'dark');
    };
    if (typeof scheme.addEventListener === 'function') {
      scheme.addEventListener('change', follow);
    }
  }

  applyLang(lang);
  applyTheme(theme);
})();
