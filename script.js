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
        return headerElement ? headerElement.offsetHeight : 0;
    }

    function scrollToTarget(targetId) {
        const headerOffset = getHeaderOffset(); // Получаем актуальную высоту шапки
        if (targetId === "#" || targetId === "#hero") {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
            // Активируем ссылку "Главная"
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
            scrollToTarget("#hero"); 
        });
    }

    // 3. Выделение активного пункта меню при скролле
    const sections = Array.from(document.querySelectorAll('main section[id]'));

    function changeNavOnScroll() {
        const headerOffset = getHeaderOffset(); // Получаем актуальную высоту шапки
        let scrollY = window.pageYOffset;
        let currentSectionId = '';

        for (let i = sections.length - 1; i >= 0; i--) {
            const section = sections[i];
            const sectionTop = section.offsetTop - headerOffset - 60; 

            if (scrollY >= sectionTop) {
                currentSectionId = section.getAttribute('id');
                break; 
            }
        }
        
        if (!currentSectionId && sections.length > 0 && scrollY < (sections[0].offsetTop - headerOffset + sections[0].offsetHeight - 60)) {
             currentSectionId = 'hero';
        }

        navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === `#${currentSectionId}`) {
                link.classList.add('active');
            }
        });
    }
    
    if (sections.length > 0) {
        window.addEventListener('scroll', changeNavOnScroll);
        changeNavOnScroll(); // Первоначальный вызов
    }

    // 4. Получение последней версии релиза с GitHub
    async function fetchLatestReleaseVersion() {
        const versionElement = document.getElementById('latest-version');
        if (!versionElement) {
            console.error('Элемент для отображения версии не найден!');
            return;
        }

        const repoOwner = 'ВАШ_НИК_НА_GITHUB'; // !!! ЗАМЕНИТЕ НА ВАШ НИК !!!
        const repoName = 'ASX-Hub';          // !!! ЗАМЕНИТЕ, ЕСЛИ ИМЯ РЕПО ДРУГОЕ !!!

        const apiUrl = `https://api.github.com/repos/${repoOwner}/${repoName}/releases/latest`;

        try {
            const response = await fetch(apiUrl);

            if (!response.ok) {
                let errorMessage = `Ошибка загрузки версии: ${response.status}`;
                if (response.status === 404) {
                    errorMessage = 'Релизы для репозитория не найдены.';
                } else if (response.status === 403) {
                    errorMessage = 'Доступ к API GitHub ограничен. Попробуйте позже.';
                    console.warn('GitHub API rate limit likely exceeded or access forbidden.');
                }
                versionElement.textContent = errorMessage;
                console.error('Failed to fetch release info:', response.status, response.statusText);
                return;
            }

            const data = await response.json();

            if (data && data.tag_name) {
                versionElement.textContent = `Последняя версия: ${data.tag_name}`;
            } else {
                versionElement.textContent = 'Не удалось определить последнюю версию.';
            }

        } catch (error) {
            versionElement.textContent = 'Ошибка при запросе версии.';
            console.error('Error fetching latest release version:', error);
        }
    }

    fetchLatestReleaseVersion(); // Вызов функции для загрузки версии

});