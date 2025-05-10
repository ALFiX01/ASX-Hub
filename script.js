document.addEventListener('DOMContentLoaded', function() {

    // 1. Установка текущего года в футере
    const yearSpan = document.getElementById('year');
    if (yearSpan) {
        yearSpan.textContent = new Date().getFullYear();
    }

    // 2. Плавная прокрутка к якорям
    const navLinks = document.querySelectorAll('header nav ul li a[href^="#"]');
    const headerElement = document.querySelector('header');
    const headerOffset = headerElement ? headerElement.offsetHeight : 0;

    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            // Специальная обработка для логотипа или ссылки "Главная", ведущей на самый верх
            if (targetId === "#" || targetId === "#hero") {
                 window.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
                // Убираем активный класс со всех, кроме "Главная", если кликнули по лого
                if (targetId === "#") {
                    document.querySelectorAll('header nav ul li a').forEach(l => l.classList.remove('active'));
                    const homeLink = document.querySelector('header nav ul li a[href="#hero"]');
                    if (homeLink) homeLink.classList.add('active');
                }
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
        });
    });

    // Обработка клика по логотипу для прокрутки вверх
    const logoLink = document.querySelector('header nav a.logo');
    if (logoLink) {
        logoLink.addEventListener('click', function(e) {
            e.preventDefault();
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
            // Сделать "Главная" активной, остальные неактивными
            document.querySelectorAll('header nav ul li a').forEach(l => l.classList.remove('active'));
            const homeLink = document.querySelector('header nav ul li a[href="#hero"]');
            if (homeLink) homeLink.classList.add('active');
        });
    }


    // 3. Выделение активного пункта меню при скролле
    const sections = document.querySelectorAll('main section[id]');
    // Обновляем headerOffset здесь, так как он мог измениться после загрузки DOM (например, из-за шрифтов)
    const dynamicHeaderOffset = headerElement ? headerElement.offsetHeight : 0;


    function changeNavOnScroll() {
        let scrollY = window.pageYOffset;
        let currentSectionId = '';

        sections.forEach(current => {
            const sectionHeight = current.offsetHeight;
            const sectionTop = current.offsetTop - dynamicHeaderOffset - 60; // 60px - небольшой запас

            if (scrollY >= sectionTop && scrollY < sectionTop + sectionHeight) {
                currentSectionId = current.getAttribute('id');
            }
        });

        navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === `#${currentSectionId}`) {
                link.classList.add('active');
            }
        });

        // Если мы в самом верху (секция hero), "Главная" должна быть активной
        const heroSection = document.getElementById('hero');
        if (heroSection && scrollY < (heroSection.offsetTop - dynamicHeaderOffset + heroSection.offsetHeight - 60) ) {
             const homeLink = document.querySelector('header nav ul li a[href="#hero"]');
             if (homeLink && !currentSectionId) { // Если никакая другая секция не активна
                navLinks.forEach(link => link.classList.remove('active')); // Сначала убрать со всех
                homeLink.classList.add('active');
             }
        } else if (!currentSectionId && scrollY < 200) { // Если наверху, но не hero (мало вероятно с текущей структурой)
            const homeLink = document.querySelector('header nav ul li a[href="#hero"]');
            if (homeLink) homeLink.classList.add('active');
        }
    }

    if (sections.length > 0) {
        window.addEventListener('scroll', changeNavOnScroll);
        changeNavOnScroll(); // Первоначальный вызов для установки состояния
    }
});