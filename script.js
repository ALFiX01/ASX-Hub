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
            scrollToTarget("#hero"); // Логотип всегда ведет на #hero (верх страницы)
        });
    }

    // 3. Выделение активного пункта меню при скролле
    const sections = Array.from(document.querySelectorAll('main section[id]'));

    function changeNavOnScroll() {
        const headerOffset = getHeaderOffset();
        let scrollY = window.pageYOffset;
        let currentSectionId = '';

        // Находим текущую секцию
        // Идем снизу вверх, чтобы правильно определить последнюю видимую секцию
        for (let i = sections.length - 1; i >= 0; i--) {
            const section = sections[i];
            const sectionTop = section.offsetTop - headerOffset - 60; // 60px - небольшой запас

            if (scrollY >= sectionTop) {
                currentSectionId = section.getAttribute('id');
                break; 
            }
        }
        
        // Если ни одна секция не найдена (например, в самом верху до первой секции),
        // или если прокрутка выше первой секции, считаем 'hero' активной
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
        changeNavOnScroll(); // Первоначальный вызов для установки состояния
    }
});