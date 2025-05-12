document.addEventListener('DOMContentLoaded', function() {

    console.log('Website version: 0.8.5'); // Обновил версию

    // 1. Установка текущего года в футере
    const yearSpan = document.getElementById('year');
    if (yearSpan) { yearSpan.textContent = new Date().getFullYear(); }

    // 2. Плавная прокрутка к якорям и обработка лого
    // ... (Код без изменений) ...
    const navLinks = document.querySelectorAll('header nav ul li a[href^="#"]');
    const logoLink = document.querySelector('header nav a.logo');
    const headerElement = document.querySelector('header');
    function getHeaderOffset() { return headerElement ? headerElement.offsetHeight : 0; }
    function scrollToTarget(targetId) { /* ... код прокрутки ... */
        const headerOffset = getHeaderOffset();
        if (targetId === "#" || targetId === "#hero") { /* ... код прокрутки вверх ... */
            window.scrollTo({ top: 0, behavior: 'smooth' });
            navLinks.forEach(l => { l.classList.remove('active'); l.removeAttribute('aria-current'); });
            const homeLink = document.querySelector('header nav ul li a[href="#hero"]');
            if (homeLink) { homeLink.classList.add('active'); homeLink.setAttribute('aria-current', 'page'); } return;
        }
        const targetElement = document.querySelector(targetId);
        if (targetElement) { /* ... код прокрутки к элементу ... */
             const elementPosition = targetElement.getBoundingClientRect().top; const offsetPosition = elementPosition + window.pageYOffset - headerOffset; window.scrollTo({ top: offsetPosition, behavior: 'smooth' });
        }
    }
    navLinks.forEach(link => { link.addEventListener('click', function(e) { e.preventDefault(); scrollToTarget(this.getAttribute('href')); }); });
    if (logoLink) { logoLink.addEventListener('click', function(e) { e.preventDefault(); scrollToTarget("#hero"); }); }


    // 3. Выделение активного пункта меню при скролле
    // ... (Код без изменений) ...
    const sections = Array.from(document.querySelectorAll('main section[id]'));
    function changeNavOnScroll() { /* ... код scrollspy ... */
        const headerOffset = getHeaderOffset(); const scrollMargin = 30; let scrollY = window.pageYOffset; let currentSectionId = '';
        for (let i = sections.length - 1; i >= 0; i--) { const section = sections[i]; const sectionTop = section.offsetTop - headerOffset - scrollMargin; if (scrollY >= sectionTop) { currentSectionId = section.getAttribute('id'); break; } }
        if (!currentSectionId && sections.length > 0 && sections[0].id === 'hero' && scrollY < (sections[0].offsetTop - headerOffset + sections[0].offsetHeight - scrollMargin) ) { currentSectionId = 'hero'; }
        navLinks.forEach(link => { link.classList.remove('active'); link.removeAttribute('aria-current'); if (link.getAttribute('href') === `#${currentSectionId}`) { link.classList.add('active'); link.setAttribute('aria-current', 'page'); } });
    }
    if (sections.length > 0 && navLinks.length > 0) { window.addEventListener('scroll', changeNavOnScroll); changeNavOnScroll(); }


    // 4. Загрузка статистики из ЛОКАЛЬНОГО файла github-stats.json
    async function fetchStatsFromFile() {
        const versionElement = document.getElementById('latest-version');
        const downloadCountElement = document.getElementById('download-count');
        const targetAssetName = 'ASX.Hub.exe'; // Используется для текста

        // Скрываем счетчик скачиваний по умолчанию
        if (downloadCountElement) {
            downloadCountElement.style.display = 'none';
            downloadCountElement.textContent = '';
        } else {
            console.warn('Элемент для отображения количества скачиваний не найден.');
        }

        // Проверяем элемент версии
        if (!versionElement) {
             console.warn('Элемент для отображения версии не найден.');
        }

        try {
            // --- ИЗМЕНЕНИЕ: Загружаем локальный файл ---
            const response = await fetch('github-stats.json');
            // ------------------------------------------

            if (!response.ok) {
                // Ошибка загрузки локального файла (маловероятно, но возможно)
                console.error('Ошибка при загрузке файла github-stats.json:', response.status, response.statusText);
                if (versionElement) {
                    versionElement.textContent = 'Ошибка загрузки статистики';
                    versionElement.style.opacity = '0.7';
                }
                // Счетчик остается скрытым
                return;
            }

            const stats = await response.json();

            // Отображаем версию из файла
            if (versionElement) {
                if (stats.latest_version && stats.latest_version !== "N/A") {
                    versionElement.textContent = `Актуальная версия: ${stats.latest_version}`;
                    versionElement.style.opacity = '1';
                } else {
                    versionElement.textContent = 'Не удалось определить версию';
                    versionElement.style.opacity = '0.7';
                }
            }

            // Отображаем скачивания из файла
            if (downloadCountElement && typeof stats.total_downloads === 'number') {
                 // Показываем только если скачивания > 0 (или можно всегда показывать, если == 0)
                 if (stats.total_downloads >= 0) {
                    downloadCountElement.textContent = `Всего скачиваний ${targetAssetName}: ${stats.total_downloads.toLocaleString()}`;
                    downloadCountElement.style.opacity = '1';
                    downloadCountElement.style.display = 'block'; // Показываем элемент
                 }
            }

            // --- УДАЛЕНО: Логика загрузки и отображения ченджлога из API ---
            // Если ченджлог все еще нужен динамически, его нужно загружать
            // отдельным unauthenticated запросом к /releases/latest
            // или включить его в github-stats.json (что усложнит Action)

        } catch (error) {
             // Ошибка JS при обработке файла или сам fetch не удался
            console.error('Ошибка при получении или обработке github-stats.json:', error);
            if (versionElement) {
                versionElement.textContent = 'Ошибка обработки статистики';
                 versionElement.style.opacity = '0.7';
            }
            // Счетчик остается скрытым
        }
    }

    // --- ИЗМЕНЕНИЕ: Вызываем новую функцию ---
    fetchStatsFromFile();
    // ---------------------------------------

    // --- УДАЛЕНО: Функция fetchLatestReleaseInfo больше не нужна в этом виде ---

    // 5. Инициализация Vanilla Tilt JS
    // ... (Код без изменений) ...
    if (typeof VanillaTilt !== 'undefined') { /* ... код Tilt ... */
        const elementsToTilt = document.querySelectorAll("[data-tilt]");
        console.log('Найдены элементы для Tilt:', elementsToTilt);
        if (elementsToTilt.length > 0) { VanillaTilt.init(elementsToTilt, { max: 12, speed: 450, glare: true, "max-glare": 0.2 }); console.log('VanillaTilt инициализирован...'); }
        else { console.warn('Не найдены элементы ... для VanillaTilt.'); }
    } else { console.warn('Библиотека VanillaTilt.js не найдена...'); }

}); // Конец DOMContentLoaded