// Common JavaScript for Employee Onboarding HTML Pages

// Mobile Navigation Toggle
function toggleMobileMenu() {
    const navMenu = document.getElementById('navMenu');
    const navToggle = document.querySelector('.nav-toggle');
    
    if (navMenu && navToggle) {
        navMenu.classList.toggle('show');
        navToggle.classList.toggle('active');
    }
}

// Set active navigation link based on current page
function setActiveNavLink() {
    const currentPage = window.location.pathname.split('/').pop();
    const navLinks = document.querySelectorAll('.nav-link');
    
    navLinks.forEach(link => {
        const linkPage = link.getAttribute('href');
        if (linkPage === currentPage) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }
    });
}

// Smooth scrolling for anchor links
function initSmoothScrolling() {
    const links = document.querySelectorAll('a[href^="#"]');
    
    links.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// Add syntax highlighting to code blocks
function highlightCodeBlocks() {
    const codeBlocks = document.querySelectorAll('pre code, .yaml-block, .config-block, .code-block');
    
    codeBlocks.forEach(block => {
        let content = block.textContent || block.innerText;
        
        // Basic YAML syntax highlighting
        content = content
            .replace(/^(\s*[a-zA-Z_][a-zA-Z0-9_]*)\s*:/gm, '<span class="key">$1</span>:')
            .replace(/:\s*([^#\r\n]+)/g, ': <span class="string">$1</span>')
            .replace(/:\s*(\d+)/g, ': <span class="number">$1</span>')
            .replace(/#.*$/gm, '<span class="comment">$&</span>');
        
        if (block.classList.contains('yaml-block') || block.classList.contains('config-block')) {
            block.innerHTML = content;
        }
    });
}

// Add copy functionality to code blocks
function addCopyButtons() {
    const codeBlocks = document.querySelectorAll('pre, .yaml-block, .config-block, .code-block');
    
    codeBlocks.forEach(block => {
        const copyButton = document.createElement('button');
        copyButton.className = 'copy-btn';
        copyButton.innerHTML = '📋 Copy';
        copyButton.style.cssText = `
            position: absolute;
            top: 0.5rem;
            left: 1rem;
            background: var(--accent-color);
            color: white;
            border: none;
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            font-size: 0.75rem;
            cursor: pointer;
            opacity: 0;
            transition: opacity 0.3s ease;
        `;
        
        block.style.position = 'relative';
        block.appendChild(copyButton);
        
        block.addEventListener('mouseenter', () => {
            copyButton.style.opacity = '1';
        });
        
        block.addEventListener('mouseleave', () => {
            copyButton.style.opacity = '0';
        });
        
        copyButton.addEventListener('click', async () => {
            const code = block.textContent || block.innerText;
            
            try {
                await navigator.clipboard.writeText(code);
                copyButton.innerHTML = '✅ Copied!';
                setTimeout(() => {
                    copyButton.innerHTML = '📋 Copy';
                }, 2000);
            } catch (err) {
                copyButton.innerHTML = '❌ Error';
                setTimeout(() => {
                    copyButton.innerHTML = '📋 Copy';
                }, 2000);
            }
        });
    });
}

// Initialize animations when elements come into view
function initScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in');
            }
        });
    }, observerOptions);
    
    // Observe cards and sections
    document.querySelectorAll('.card, .nav-card, .stat-card').forEach(el => {
        observer.observe(el);
    });
}

// Search functionality (if search input exists)
function initSearch() {
    const searchInput = document.getElementById('searchInput');
    if (!searchInput) return;
    
    const searchableElements = document.querySelectorAll('.nav-card, .card, h1, h2, h3, p');
    
    searchInput.addEventListener('input', (e) => {
        const searchTerm = e.target.value.toLowerCase();
        
        searchableElements.forEach(element => {
            const text = element.textContent.toLowerCase();
            const parent = element.closest('.nav-card') || element.closest('.card') || element;
            
            if (text.includes(searchTerm) || searchTerm === '') {
                parent.style.display = '';
            } else {
                parent.style.display = 'none';
            }
        });
    });
}

// Theme toggle functionality
function initThemeToggle() {
    const themeToggle = document.getElementById('themeToggle');
    if (!themeToggle) return;
    
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const currentTheme = localStorage.getItem('theme') || (prefersDark ? 'dark' : 'light');
    
    document.documentElement.setAttribute('data-theme', currentTheme);
    
    themeToggle.addEventListener('click', () => {
        const currentTheme = document.documentElement.getAttribute('data-theme');
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
        
        document.documentElement.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);
    });
}

// Back to top button
function initBackToTop() {
    const backToTopButton = document.createElement('button');
    backToTopButton.innerHTML = '↑';
    backToTopButton.className = 'back-to-top';
    backToTopButton.style.cssText = `
        position: fixed;
        bottom: 2rem;
        right: 2rem;
        width: 3rem;
        height: 3rem;
        border-radius: 50%;
        background: var(--primary-color);
        color: white;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        opacity: 0;
        transition: all 0.3s ease;
        z-index: 1000;
        box-shadow: var(--shadow-lg);
    `;
    
    document.body.appendChild(backToTopButton);
    
    window.addEventListener('scroll', () => {
        if (window.pageYOffset > 300) {
            backToTopButton.style.opacity = '1';
        } else {
            backToTopButton.style.opacity = '0';
        }
    });
    
    backToTopButton.addEventListener('click', () => {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
}

// Print functionality
function printPage() {
    window.print();
}

// Initialize all functionality when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    setActiveNavLink();
    initSmoothScrolling();
    highlightCodeBlocks();
    addCopyButtons();
    initScrollAnimations();
    initSearch();
    initThemeToggle();
    initBackToTop();
    
    // Add print button if it exists
    const printBtn = document.getElementById('printBtn');
    if (printBtn) {
        printBtn.addEventListener('click', printPage);
    }
});

// Close mobile menu when clicking outside
document.addEventListener('click', function(event) {
    const navMenu = document.getElementById('navMenu');
    const navToggle = document.querySelector('.nav-toggle');
    
    if (navMenu && navToggle && !navToggle.contains(event.target) && !navMenu.contains(event.target)) {
        navMenu.classList.remove('show');
        navToggle.classList.remove('active');
    }
});

// Handle window resize
window.addEventListener('resize', function() {
    const navMenu = document.getElementById('navMenu');
    if (navMenu && window.innerWidth > 768) {
        navMenu.classList.remove('show');
        document.querySelector('.nav-toggle')?.classList.remove('active');
    }
});

// Keyboard navigation support
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        const navMenu = document.getElementById('navMenu');
        if (navMenu && navMenu.classList.contains('show')) {
            navMenu.classList.remove('show');
            document.querySelector('.nav-toggle')?.classList.remove('active');
        }
    }
});
