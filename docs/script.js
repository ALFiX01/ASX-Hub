document.addEventListener('DOMContentLoaded', function() {

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
        // Динамически получаем высоту шапки, т.к. она может меняться (например, при ресайзе или добавлении/удалении контента в ней)
        return headerElement ? headerElement.offsetHeight : 0;
    }

    function scrollToTarget(targetId) {
        const headerOffset = getHeaderOffset(); 
        if (targetId === "#" || targetId === "#hero") { // Прокрутка к самому верху или к секции hero
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
            // Активируем ссылку "Главная" (если она есть и ведет на #hero)
            navLinks.forEach(l => l.classList.remove('active'));
            const homeLink = document.querySelector('header nav ul li a[href="#hero"]');
            if (homeLink) homeLink.classList.add('active');
            return;
        }

        const targetElement = document.querySelector(targetId);
        if (targetElement) {
            const elementPosition = targetElement.getBoundingClientRect().top;
            const offsetPosition = elementPosition + window.pageYOffset - headerOffset;

            window.scrollTo({
                top: offsetPosition,
                behavior: 'smooth'
            });
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
            scrollToTarget("#hero"); // Логотип всегда ведет на #hero (или самый верх)
        });
    }

    // 3. Выделение активного пункта меню при скролле
    const sections = Array.from(document.querySelectorAll('main section[id]')); // Собираем все секции с ID в main

    function changeNavOnScroll() {
        const headerOffset = getHeaderOffset();
        let scrollY = window.pageYOffset;
        let currentSectionId = '';

        // Идем по секциям и определяем, какая сейчас активна
        // (начиная с последней, чтобы правильно определить, если несколько секций видны одновременно)
        for (let i = sections.length - 1; i >= 0; i--) {
            const section = sections[i];
            // Учитываем высоту шапки и добавляем небольшой запас (например, 60px)
            // чтобы секция считалась активной чуть раньше, чем ее самый верх коснется шапки
            const sectionTop = section.offsetTop - headerOffset - 60; 

            if (scrollY >= sectionTop) {
                currentSectionId = section.getAttribute('id');
                break; // Нашли активную секцию, выходим из цикла
            }
        }
        
        // Если не найдена активная секция (например, мы в самом верху, выше первой секции с id="hero")
        // или если currentSectionId пуст, но мы близко к верху и есть секция hero
        if (!currentSectionId && sections.length > 0 && sections[0].id === 'hero' && scrollY < (sections[0].offsetTop - headerOffset + sections[0].offsetHeight - 60) ) {
             currentSectionId = 'hero';
        }


        navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === `#${currentSectionId}`) {
                link.classList.add('active');
            }
        });
    }
    
    // Вызываем функцию при загрузке и при скролле, если есть секции для отслеживания
    if (sections.length > 0 && navLinks.length > 0) {
        window.addEventListener('scroll', changeNavOnScroll);
        changeNavOnScroll(); // Первоначальный вызов для установки правильного активного пункта
    }

    // 4. Получение последней версии релиза и патч-ноута с GitHub
    async function fetchLatestReleaseInfo() {
        const versionElement = document.getElementById('latest-version');
        const changelogVersionElement = document.getElementById('changelog-version');
        const changelogBodyElement = document.getElementById('changelog-body');

        if (!versionElement && !changelogVersionElement && !changelogBodyElement) {
            // console.warn('Элементы для версии или патч-ноута не найдены. Пропускаем загрузку с GitHub.');
            return; // Тихо выходим, если ни одного элемента нет, чтобы не засорять консоль при отсутствии этих блоков
        }
        
        const repoOwner = 'ALFiX01'; // !!! ЗАМЕНИТЕ НА ВАШ НИК, ЕСЛИ ОТЛИЧАЕТСЯ !!!
        const repoName = 'ASX-Hub';  // !!! ЗАМЕНИТЕ, ЕСЛИ ИМЯ РЕПО ДРУГОЕ !!!
        const apiUrl = `https://api.github.com/repos/${repoOwner}/${repoName}/releases/latest`;

        try {
            const response = await fetch(apiUrl);
            let errorMessage = '';

            if (!response.ok) {
                errorMessage = `Ошибка загрузки данных: ${response.status}`;
                if (response.status === 404) {
                    errorMessage = 'Релизы для репозитория не найдены.';
                } else if (response.status === 403) {
                    errorMessage = 'Доступ к API GitHub ограничен. Попробуйте позже.';
                }
                console.error('Failed to fetch release info:', response.status, response.statusText);
                
                if (versionElement) versionElement.textContent = errorMessage;
                if (changelogVersionElement) changelogVersionElement.textContent = 'Ошибка';
                if (changelogBodyElement) changelogBodyElement.innerHTML = `<p>${errorMessage}</p>`;
                return;
            }

            const data = await response.json();

            if (data && data.tag_name) {
                if (versionElement) {
                    versionElement.textContent = `Последняя версия: ${data.tag_name}`;
                }
                if (changelogVersionElement) {
                    changelogVersionElement.textContent = data.tag_name;
                }

                if (changelogBodyElement && data.body) {
                    if (typeof marked === 'function') { // Проверяем, загружена ли библиотека marked.js
                        changelogBodyElement.innerHTML = marked.parse(data.body);
                    } else {
                        changelogBodyElement.innerHTML = `<pre>${data.body.replace(/</g, "<").replace(/>/g, ">")}</pre>`;
                        console.warn('Библиотека marked.js не найдена. Патч-ноут отображается как простой текст.');
                    }
                } else if (changelogBodyElement) {
                    changelogBodyElement.innerHTML = '<p>Описание для этого релиза отсутствует.</p>';
                }
            } else {
                if (versionElement) versionElement.textContent = 'Не удалось определить версию.';
                if (changelogVersionElement) changelogVersionElement.textContent = 'N/A';
                if (changelogBodyElement) changelogBodyElement.innerHTML = '<p>Не удалось загрузить информацию о релизе.</p>';
            }

        } catch (error) {
            console.error('Error fetching latest release info:', error);
            if (versionElement) versionElement.textContent = 'Ошибка при запросе.';
            if (changelogVersionElement) changelogVersionElement.textContent = 'Ошибка';
            if (changelogBodyElement) changelogBodyElement.innerHTML = '<p>Ошибка при запросе информации.</p>';
        }
    }

    // Вызываем функцию для загрузки информации с GitHub
    fetchLatestReleaseInfo();

    // 5. Инициализация Vanilla Tilt JS
    // Библиотека сама находит элементы с атрибутом data-tilt,
    // но если нужна более тонкая настройка для всех элементов или специфическая инициализация:
    if (typeof VanillaTilt !== 'undefined') { // Проверяем, загружена ли библиотека
        VanillaTilt.init(document.querySelectorAll("[data-tilt]"), {
            max: 15,         // Максимальный угол наклона
            speed: 400,      // Скорость анимации
            glare: true,     // Включить блик
            "max-glare": 0.3 // Максимальная интенсивность блика
            // Другие опции можно найти в документации VanillaTilt
        });
    } else {
        console.warn('Библиотека VanillaTilt.js не найдена.');
    }

});