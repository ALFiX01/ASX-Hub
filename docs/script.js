document.addEventListener('DOMContentLoaded', function() {

    console.log('Website version: 0.8.6'); // Обновил версию (или ваша актуальная)

    // 1. Установка текущего года в футере
    const yearSpan = document.getElementById('year');
    if (yearSpan) {
        yearSpan.textContent = new Date().getFullYear();
    }

    // 2. Плавная прокрутка к якорям и обработка лого
    const navLinks = document.querySelectorAll('header nav ul li a[href^="#"]');
    const logoLink = document.querySelector('header nav a.logo');
    const headerElement = document.querySelector('header');

    function getHeaderOffset() {
        return headerElement ? headerElement.offsetHeight : 0;
    }

    function scrollToTarget(targetId) {
        const headerOffset = getHeaderOffset();

        if (targetId === "#" || targetId === "#hero") {
            window.scrollTo({ top: 0, behavior: 'smooth' });
            navLinks.forEach(l => {
                l.classList.remove('active');
                l.removeAttribute('aria-current');
            });
            const homeLink = document.querySelector('header nav ul li a[href="#hero"]');
            if (homeLink) {
                homeLink.classList.add('active');
                homeLink.setAttribute('aria-current', 'page');
            }
            return;
        }

        const targetElement = document.querySelector(targetId);
        if (targetElement) {
            const elementPosition = targetElement.getBoundingClientRect().top;
            const offsetPosition = elementPosition + window.pageYOffset - headerOffset;
            window.scrollTo({ top: offsetPosition, behavior: 'smooth' });
        }
    }

    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            scrollToTarget(this.getAttribute('href'));
        });
    });

    if (logoLink) {
        logoLink.addEventListener('click', function(e) {
            e.preventDefault();
            scrollToTarget("#hero"); 
        });
    }

    // 3. Выделение активного пункта меню при скролле
    const sections = Array.from(document.querySelectorAll('main section[id]'));

    function changeNavOnScroll() {
        const headerOffset = getHeaderOffset();
        const scrollMargin = 30; 
        let scrollY = window.pageYOffset;
        let currentSectionId = '';

        for (let i = sections.length - 1; i >= 0; i--) {
            const section = sections[i];
            const sectionTop = section.offsetTop - headerOffset - scrollMargin;
            if (scrollY >= sectionTop) {
                currentSectionId = section.getAttribute('id');
                break;
            }
        }
        
        if (!currentSectionId && sections.length > 0 && sections[0].id === 'hero' && scrollY < (sections[0].offsetTop - headerOffset + sections[0].offsetHeight - scrollMargin) ) {
            currentSectionId = 'hero';
        }

        navLinks.forEach(link => {
            link.classList.remove('active');
            link.removeAttribute('aria-current');
            if (link.getAttribute('href') === `#${currentSectionId}`) {
                link.classList.add('active');
                link.setAttribute('aria-current', 'page');
            }
        });
    }

    if (sections.length > 0 && navLinks.length > 0) {
        window.addEventListener('scroll', changeNavOnScroll);
        changeNavOnScroll(); 
    }


    // 4. Загрузка статистики из ЛОКАЛЬНОГО файла github-stats.json
    async function fetchStatsFromFile() {
        const versionElement = document.getElementById('latest-version');
        const downloadCountElement = document.getElementById('download-count');
        const changelogSection = document.getElementById('changelog-section');
        const changelogBodyEl = document.getElementById('changelog-body');
        const changelogVersionSpan = document.getElementById('changelog-version');
        const schemaScript = document.querySelector('script[type="application/ld+json"]');

        // Установка начальных состояний
        if (versionElement) versionElement.textContent = 'Загрузка актуальной версии...';
        if (downloadCountElement) downloadCountElement.style.display = 'none';
        
        if (changelogSection) {
            changelogSection.classList.remove('visible'); // Убедимся, что секция скрыта (управляется CSS display:none по умолчанию)
        }
        if (changelogBodyEl) {
            changelogBodyEl.innerHTML = '<p>Загрузка информации о последних изменениях...</p>';
        }
        if (changelogVersionSpan) {
            changelogVersionSpan.textContent = ''; // Очищаем версию в заголовке
        }

        const defaultRepoOwner = 'ALFiX01';
        const defaultRepoName = 'ASX-Hub';
        const releasesPageUrl = (owner, name) => `https://github.com/${owner || defaultRepoOwner}/${name || defaultRepoName}/releases`;

        try {
            const response = await fetch('github-stats.json'); 

            if (!response.ok) {
                console.error('Ошибка при загрузке файла github-stats.json:', response.status, response.statusText);
                if (versionElement) {
                    versionElement.textContent = 'Ошибка загрузки статистики';
                    versionElement.style.opacity = '0.7';
                }
                if (changelogBodyEl && changelogSection && changelogVersionSpan) {
                     changelogBodyEl.innerHTML = `<p>Не удалось загрузить информацию об изменениях. Пожалуйста, проверьте <a href="${releasesPageUrl()}" target="_blank" rel="noopener noreferrer">страницу релизов на GitHub</a>.</p>`;
                     changelogVersionSpan.textContent = "ошибка";
                     changelogSection.classList.add('visible');
                }
                return;
            }

            const stats = await response.json();
            const repoOwner = stats.repo_owner || defaultRepoOwner;
            const repoName = stats.repo_name || defaultRepoName;

            // Отображаем версию
            if (versionElement) {
                if (stats.latest_version && stats.latest_version !== "N/A") {
                    versionElement.textContent = `Актуальная версия: ${stats.latest_version}`;
                    versionElement.style.opacity = '1';

                    if (schemaScript) {
                        try {
                            const schemaData = JSON.parse(schemaScript.textContent);
                            schemaData.softwareVersion = stats.latest_version;
                            schemaScript.textContent = JSON.stringify(schemaData, null, 2);
                        } catch (e) {
                            console.warn("Не удалось обновить softwareVersion в Schema.org JSON-LD:", e);
                        }
                    }
                } else {
                    versionElement.textContent = 'Не удалось определить версию';
                    versionElement.style.opacity = '0.7';
                }
            }

            // Отображаем скачивания
            if (downloadCountElement && typeof stats.total_downloads === 'number') {
                 if (stats.total_downloads >= 0) { 
                    downloadCountElement.textContent = `Cкачиваний: ${stats.total_downloads.toLocaleString()}`;
                    downloadCountElement.style.opacity = '1';
                    downloadCountElement.style.display = 'block';
                 }
            }

            // Отображаем ченджлог
            if (changelogSection && changelogBodyEl && changelogVersionSpan) {
                if (stats.latest_release_body && stats.latest_version && stats.latest_version !== "N/A") {
                    // Успешное отображение ченджлога
                    if (typeof showdown !== 'undefined') {
                        const converter = new showdown.Converter({
                            simplifiedAutoLink: true,
                            strikethrough: true,
                            tables: true,
                            tasklists: true,
                            openLinksInNewWindow: true,
                            ghCompatibleHeaderId: true
                        });
                        changelogBodyEl.innerHTML = converter.makeHtml(stats.latest_release_body);
                    } else {
                        console.warn('Showdown.js не загружен. Changelog не может быть отформатирован.');
                        changelogBodyEl.innerHTML = `<p>Не удалось отформатировать описание изменений. Пожалуйста, проверьте <a href="${releasesPageUrl(repoOwner, repoName)}" target="_blank" rel="noopener noreferrer">страницу релизов на GitHub</a>.</p>`;
                    }
                    changelogVersionSpan.textContent = stats.latest_version;
                    changelogSection.classList.add('visible');
                } else {
                    // Данные для ченджлога неполные или отсутствуют
                    console.warn('Данные для ченджлога (latest_release_body или latest_version) не найдены, или версия "N/A". Секция ченджлога будет отображена с сообщением.');
                    changelogBodyEl.innerHTML = `<p>Информация о последних изменениях отсутствует или неполная. Вы можете ознакомиться со всеми изменениями на <a href="${releasesPageUrl(repoOwner, repoName)}" target="_blank" rel="noopener noreferrer">странице релизов GitHub</a>.</p>`;
                    
                    if (stats.latest_version && stats.latest_version !== "N/A") {
                        changelogVersionSpan.textContent = stats.latest_version;
                    } else {
                        changelogVersionSpan.textContent = "N/A"; // Отобразит "Последние изменения (N/A)"
                    }
                    changelogSection.classList.add('visible'); // Показываем секцию с этим сообщением
                }
            }

        } catch (error) {
            console.error('Ошибка при получении или обработке github-stats.json:', error);
            if (versionElement) {
                versionElement.textContent = 'Ошибка обработки статистики';
                versionElement.style.opacity = '0.7';
            }
             if (changelogBodyEl && changelogSection && changelogVersionSpan) {
                 changelogBodyEl.innerHTML = `<p>Ошибка при загрузке информации об изменениях. Пожалуйста, проверьте <a href="${releasesPageUrl()}" target="_blank" rel="noopener noreferrer">страницу релизов на GitHub</a>.</p>`;
                 changelogVersionSpan.textContent = "ошибка";
                 changelogSection.classList.add('visible');
            }
        }
    }

    fetchStatsFromFile();


    // 5. Инициализация Vanilla Tilt JS
    if (typeof VanillaTilt !== 'undefined') {
        const elementsToTilt = document.querySelectorAll("[data-tilt]");
        if (elementsToTilt.length > 0) {
            VanillaTilt.init(elementsToTilt, {
                max: 12,        
                speed: 450,     
                glare: true,    
                "max-glare": 0.2 
            });
            console.log('VanillaTilt инициализирован для ' + elementsToTilt.length + ' элементов.');
        } else {
            console.warn('Не найдены элементы с атрибутом [data-tilt] для VanillaTilt.');
        }
    } else {
        console.warn('Библиотека VanillaTilt.js не найдена. Эффект наклона не будет применен.');
    }

});