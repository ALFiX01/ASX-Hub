document.addEventListener('DOMContentLoaded', function() {

    console.log('Website version: 0.8.1'); // Обновил версию для отслеживания изменений

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
        // Возвращаем высоту шапки, если она есть, иначе 0
        return headerElement ? headerElement.offsetHeight : 0;
    }

    function scrollToTarget(targetId) {
        const headerOffset = getHeaderOffset();
        // Прокрутка наверх для # и #hero
        if (targetId === "#" || targetId === "#hero") {
            window.scrollTo({ top: 0, behavior: 'smooth' });
            // Снимаем active со всех ссылок и добавляем на Главную
            navLinks.forEach(l => l.classList.remove('active'));
            const homeLink = document.querySelector('header nav ul li a[href="#hero"]');
            if (homeLink) homeLink.classList.add('active');
            return; // Выходим из функции
        }

        const targetElement = document.querySelector(targetId);
        if (targetElement) {
            const elementPosition = targetElement.getBoundingClientRect().top;
            // Рассчитываем позицию с учетом шапки
            const offsetPosition = elementPosition + window.pageYOffset - headerOffset;

            window.scrollTo({ top: offsetPosition, behavior: 'smooth' });
        }
    }

    // Навешиваем обработчики на ссылки навигации
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault(); // Отменяем стандартный переход
            scrollToTarget(this.getAttribute('href')); // Вызываем нашу функцию прокрутки
        });
    });

    // Навешиваем обработчик на логотип
    if (logoLink) {
        logoLink.addEventListener('click', function(e) {
            e.preventDefault();
            scrollToTarget("#hero"); // Прокрутка к #hero при клике на лого
        });
    }

    // 3. Выделение активного пункта меню при скролле
    const sections = Array.from(document.querySelectorAll('main section[id]'));

    function changeNavOnScroll() {
        const headerOffset = getHeaderOffset();
        const scrollMargin = 30; // Увеличил отступ для более точного срабатывания
        let scrollY = window.pageYOffset;
        let currentSectionId = '';

        // Идем по секциям снизу вверх
        for (let i = sections.length - 1; i >= 0; i--) {
            const section = sections[i];
            // Рассчитываем верхнюю границу секции с учетом шапки и отступа
            const sectionTop = section.offsetTop - headerOffset - scrollMargin;

            // Если текущая прокрутка больше или равна верху секции
            if (scrollY >= sectionTop) {
                currentSectionId = section.getAttribute('id');
                break; // Нашли активную секцию, выходим из цикла
            }
        }

        // Особый случай для секции Hero, если ничего другого не найдено
        if (!currentSectionId && sections.length > 0 && sections[0].id === 'hero' && scrollY < (sections[0].offsetTop - headerOffset + sections[0].offsetHeight - scrollMargin) ) {
             currentSectionId = 'hero';
        }

        // Обновляем классы 'active' у ссылок навигации
        navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === `#${currentSectionId}`) {
                link.classList.add('active');
            }
        });
    }

    // Добавляем слушатель скролла, если есть секции и ссылки
    if (sections.length > 0 && navLinks.length > 0) {
        window.addEventListener('scroll', changeNavOnScroll);
        changeNavOnScroll(); // Вызываем один раз при загрузке
    }

    // 4. Получение последней версии релиза и патч-ноута с GitHub
    async function fetchLatestReleaseInfo() {
        const versionElement = document.getElementById('latest-version');
        const changelogSectionElement = document.getElementById('changelog-section');
        const changelogVersionElement = document.getElementById('changelog-version');
        const changelogBodyElement = document.getElementById('changelog-body');

        // Если нет ключевых элементов, выходим
        if (!versionElement && !changelogSectionElement) {
            console.warn('Элементы для отображения версии или ченджлога не найдены.');
            return;
        }

        const repoOwner = 'ALFiX01';
        const repoName = 'ASX-Hub';
        const apiUrl = `https://api.github.com/repos/${repoOwner}/${repoName}/releases/latest`;

        try {
            const response = await fetch(apiUrl);

            // Улучшенная обработка ошибок ответа API
            if (!response.ok) {
                console.error('Ошибка при загрузке данных с GitHub:', response.status, response.statusText);
                const friendlyErrorMessage = 'Не удалось загрузить информацию о последней версии.';
                if (versionElement) {
                    versionElement.textContent = friendlyErrorMessage;
                    // Можно добавить стиль, чтобы показать, что это ошибка
                    versionElement.style.opacity = '0.7';
                }
                 // Скрываем секцию ченджлога при любой ошибке
                if (changelogSectionElement) {
                    changelogSectionElement.classList.remove('visible');
                }
                return; // Выходим из функции
            }

            const data = await response.json();

            if (data && data.tag_name) {
                // Отображаем версию
                if (versionElement) {
                    versionElement.textContent = `Актуальная версия: ${data.tag_name}`;
                    versionElement.style.opacity = '1'; // Возвращаем нормальную прозрачность
                }

                // Отображаем ченджлог, если есть нужные элементы
                if (changelogBodyElement && changelogVersionElement) {
                    changelogVersionElement.textContent = data.tag_name;

                    if (data.body) {
                        // Используем Showdown для конвертации Markdown в HTML
                        if (typeof showdown !== 'undefined' && typeof showdown.Converter === 'function') {
                            const converter = new showdown.Converter({
                                ghCompatibleHeaderId: true,
                                simpleLineBreaks: true,
                                tables: true,
                                strikethrough: true,
                                tasklists: true,
                                openLinksInNewWindow: true,
                                emoji: true
                            });
                            changelogBodyElement.innerHTML = converter.makeHtml(data.body);
                        } else {
                            // Запасной вариант: показать как простой текст
                            changelogBodyElement.innerHTML = `<pre>${data.body.replace(/</g, "<").replace(/>/g, ">")}</pre>`;
                            console.warn('Библиотека Showdown.js не найдена. Ченджлог отображен как простой текст.');
                        }
                    } else {
                        changelogBodyElement.innerHTML = '<p>Описание для этого релиза отсутствует.</p>';
                    }

                    // Показываем секцию ченджлога
                    if (changelogSectionElement) {
                       changelogSectionElement.classList.add('visible');
                    }
                } else if (changelogSectionElement) {
                    // Если нет элементов для контента, но есть секция - скрываем
                     changelogSectionElement.classList.remove('visible');
                     console.warn('Элементы для отображения содержимого ченджлога не найдены.');
                }

            } else {
                 // Если данные некорректные
                console.warn('Получены некорректные данные от GitHub API:', data);
                if (versionElement) {
                    versionElement.textContent = 'Не удалось определить версию.';
                    versionElement.style.opacity = '0.7';
                }
                if (changelogSectionElement) {
                    changelogSectionElement.classList.remove('visible');
                }
            }

        } catch (error) {
             // Обработка сетевых ошибок или ошибок JS
            console.error('Ошибка при выполнении запроса к GitHub API:', error);
            if (versionElement) {
                versionElement.textContent = 'Ошибка при запросе.';
                 versionElement.style.opacity = '0.7';
            }
            if (changelogSectionElement) {
                changelogSectionElement.classList.remove('visible');
            }
        }
    }

    fetchLatestReleaseInfo(); // Запускаем загрузку данных

    // 5. Инициализация Vanilla Tilt JS
    if (typeof VanillaTilt !== 'undefined') {
        // Находим все элементы с атрибутом data-tilt
        const elementsToTilt = document.querySelectorAll("[data-tilt]");
        console.log('Найдены элементы для Tilt:', elementsToTilt);

        // Инициализируем Tilt ТОЛЬКО если элементы найдены
        if (elementsToTilt.length > 0) {
            VanillaTilt.init(elementsToTilt, {
                max: 12, // Немного уменьшил максимальный наклон
                speed: 450, // Чуть медленнее
                glare: true, // Включил небольшое свечение
                "max-glare": 0.2 // Интенсивность свечения
            });
            console.log('VanillaTilt инициализирован для', elementsToTilt.length, 'элементов');
        } else {
            console.warn('Не найдены элементы с атрибутом [data-tilt] для инициализации VanillaTilt.');
        }
    } else {
         // Если библиотека не загрузилась
         console.warn('Библиотека VanillaTilt.js не найдена или не загружена.');
    }
});