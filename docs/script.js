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
        const headerOffset = getHeaderOffset(); 
        if (targetId === "#" || targetId === "#hero") {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
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
        const headerOffset = getHeaderOffset();
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
    
    if (sections.length > 0 && navLinks.length > 0) {
        window.addEventListener('scroll', changeNavOnScroll);
        changeNavOnScroll();
    }

    // 4. Получение последней версии релиза и патч-ноута с GitHub
    async function fetchLatestReleaseInfo() {
        const versionElement = document.getElementById('latest-version');
        const changelogSectionElement = document.getElementById('changelog-section');
        const changelogVersionElement = document.getElementById('changelog-version');
        const changelogBodyElement = document.getElementById('changelog-body');

        if (!versionElement && !changelogSectionElement) {
            return; 
        }
        
        const repoOwner = 'ALFiX01'; 
        const repoName = 'ASX-Hub';  
        const apiUrl = `https://api.github.com/repos/${repoOwner}/${repoName}/releases/latest`;

        try {
            const response = await fetch(apiUrl);
            
            if (!response.ok) {
                console.error('Failed to fetch release info:', response.status, response.statusText);
                if (response.status === 403 && versionElement) {
                     versionElement.textContent = 'Последняя версия: (API лимит)';
                } else if (versionElement) {
                    versionElement.textContent = `Ошибка загрузки версии: ${response.status}`;
                }
                if (changelogSectionElement) {
                    changelogSectionElement.classList.remove('visible');
                }
                return;
            }

            const data = await response.json();

            if (data && data.tag_name) {
                if (versionElement) {
                    versionElement.textContent = `Последняя версия: ${data.tag_name}`;
                }

                if (changelogBodyElement && changelogVersionElement) { // Проверяем наличие обоих элементов для changelog
                    changelogVersionElement.textContent = data.tag_name;

                    if (data.body) {
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
                            changelogBodyElement.innerHTML = `<pre>${data.body.replace(/</g, "<").replace(/>/g, ">")}</pre>`;
                            console.warn('Библиотека Showdown.js не найдена. Патч-ноут отображается как простой текст.');
                        }
                    } else {
                        changelogBodyElement.innerHTML = '<p>Описание для этого релиза отсутствует.</p>';
                    }
                    
                    if (changelogSectionElement) {
                       changelogSectionElement.classList.add('visible');
                    }
                } else if (changelogSectionElement) { // Если нет элементов для тела/версии ченджлога, но есть сама секция, скрыть ее
                     changelogSectionElement.classList.remove('visible');
                }

            } else {
                if (versionElement) versionElement.textContent = 'Не удалось определить версию.';
                if (changelogSectionElement) {
                    changelogSectionElement.classList.remove('visible');
                }
            }

        } catch (error) {
            console.error('Error fetching latest release info:', error);
            if (versionElement) versionElement.textContent = 'Ошибка при запросе.';
            if (changelogSectionElement) {
                changelogSectionElement.classList.remove('visible');
            }
        }
    }

    fetchLatestReleaseInfo();

    // 5. Инициализация Vanilla Tilt JS
    if (typeof VanillaTilt !== 'undefined') {
        VanillaTilt.init(document.querySelectorAll("[data-tilt]"), {
            reverse: true,
            max: 16,
            speed: 400,
            glare: true,
            "max-glare": 0.3
        });
    } else {
        // console.warn('Библиотека VanillaTilt.js не найдена.');
    }
});