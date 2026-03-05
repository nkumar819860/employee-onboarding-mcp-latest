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

// Advanced YAML Parser and Formatter
class YamlProcessor {
    constructor() {
        this.errors = [];
        this.warnings = [];
    }

    // Basic YAML parser for validation
    parseYaml(content) {
        this.errors = [];
        this.warnings = [];
        const lines = content.split('\n');
        let inMultiline = false;
        let indentStack = [0];
        
        lines.forEach((line, index) => {
            const lineNum = index + 1;
            const trimmed = line.trim();
            
            // Skip empty lines and comments
            if (!trimmed || trimmed.startsWith('#')) return;
            
            // Check indentation
            const indent = line.length - line.trimStart().length;
            
            // Validate indentation consistency
            if (indent % 2 !== 0 && indent !== 0) {
                this.errors.push({
                    line: lineNum,
                    message: 'Inconsistent indentation (should be multiples of 2)',
                    type: 'indentation'
                });
            }
            
            // Check for tabs
            if (line.includes('\t')) {
                this.errors.push({
                    line: lineNum,
                    message: 'Use spaces instead of tabs for indentation',
                    type: 'indentation'
                });
            }
            
            // Check for trailing spaces
            if (line.endsWith(' ')) {
                this.warnings.push({
                    line: lineNum,
                    message: 'Trailing whitespace detected',
                    type: 'formatting'
                });
            }
            
            // Validate key-value pairs
            if (line.includes(':')) {
                const colonIndex = line.indexOf(':');
                const key = line.substring(0, colonIndex).trim();
                const value = line.substring(colonIndex + 1).trim();
                
                // Check for space after colon
                if (line[colonIndex + 1] !== ' ' && line[colonIndex + 1] !== '\n' && line[colonIndex + 1] !== undefined) {
                    this.errors.push({
                        line: lineNum,
                        message: 'Missing space after colon',
                        type: 'syntax'
                    });
                }
                
                // Check for valid key format
                if (!/^[a-zA-Z_][a-zA-Z0-9_-]*$/.test(key) && !key.match(/^['"][^'"]*['"]$/)) {
                    this.warnings.push({
                        line: lineNum,
                        message: 'Key should be alphanumeric or quoted',
                        type: 'syntax'
                    });
                }
            }
            
            // Check for proper list formatting
            if (trimmed.startsWith('- ')) {
                if (!line.match(/^\s*- /)) {
                    this.errors.push({
                        line: lineNum,
                        message: 'List items should have space after dash',
                        type: 'syntax'
                    });
                }
            }
        });
        
        return {
            errors: this.errors,
            warnings: this.warnings,
            isValid: this.errors.length === 0
        };
    }

    // Format YAML content
    formatYaml(content) {
        const lines = content.split('\n');
        const formatted = [];
        let currentIndent = 0;
        
        lines.forEach(line => {
            const trimmed = line.trim();
            
            // Skip empty lines but preserve them
            if (!trimmed) {
                formatted.push('');
                return;
            }
            
            // Preserve comments
            if (trimmed.startsWith('#')) {
                formatted.push(' '.repeat(currentIndent) + trimmed);
                return;
            }
            
            // Handle list items
            if (trimmed.startsWith('-')) {
                const content = trimmed.substring(1).trim();
                formatted.push(' '.repeat(currentIndent) + '- ' + content);
                return;
            }
            
            // Handle key-value pairs
            if (line.includes(':')) {
                const colonIndex = line.indexOf(':');
                const key = line.substring(0, colonIndex).trim();
                const value = line.substring(colonIndex + 1).trim();
                
                if (value) {
                    formatted.push(' '.repeat(currentIndent) + key + ': ' + value);
                } else {
                    formatted.push(' '.repeat(currentIndent) + key + ':');
                    currentIndent += 2;
                }
            } else {
                formatted.push(' '.repeat(currentIndent) + trimmed);
            }
        });
        
        return formatted.join('\n');
    }

    // Advanced syntax highlighting
    highlightYaml(content) {
        let highlighted = content
            // Highlight comments
            .replace(/(#.*$)/gm, '<span class="comment">$1</span>')
            // Highlight string values in quotes
            .replace(/(['"])((?:\\.|(?!\1)[^\\])*?)\1/g, '<span class="string">$1$2$1</span>')
            // Highlight numbers
            .replace(/:\s*(-?\d*\.?\d+([eE][-+]?\d+)?)/g, ': <span class="number">$1</span>')
            // Highlight booleans
            .replace(/:\s*(true|false|yes|no|on|off)/gi, ': <span class="boolean">$1</span>')
            // Highlight null values
            .replace(/:\s*(null|~)/gi, ': <span class="null">$1</span>')
            // Highlight keys
            .replace(/^(\s*)([a-zA-Z_][a-zA-Z0-9_-]*)\s*:/gm, '$1<span class="key">$2</span>:')
            // Highlight operators and special characters
            .replace(/([:\[\]{}|>-])/g, '<span class="operator">$1</span>')
            // Highlight list indicators
            .replace(/^(\s*)(-)\s+/gm, '$1<span class="operator">$2</span> ');
            
        return highlighted;
    }
}

// Enhanced code block highlighting and processing
function highlightCodeBlocks() {
    const yamlProcessor = new YamlProcessor();
    const codeBlocks = document.querySelectorAll('pre code, .yaml-block, .config-block, .code-block');
    
    codeBlocks.forEach(block => {
        let content = block.textContent || block.innerText;
        
        if (block.classList.contains('yaml-block') || block.classList.contains('config-block')) {
            // Add YAML validation and highlighting
            const validation = yamlProcessor.parseYaml(content);
            const highlighted = yamlProcessor.highlightYaml(content);
            
            block.innerHTML = highlighted;
            
            // Add validation indicators
            addValidationIndicators(block, validation);
            
            // Add format button
            addFormatButton(block, content, yamlProcessor);
        } else {
            // Basic syntax highlighting for other code blocks
            const highlighted = content
                .replace(/(['"])((?:\\.|(?!\1)[^\\])*?)\1/g, '<span class="string">$1$2$1</span>')
                .replace(/\b(\d+\.?\d*)\b/g, '<span class="number">$1</span>')
                .replace(/(\/\/.*$|\/\*[\s\S]*?\*\/)/gm, '<span class="comment">$1</span>');
            
            block.innerHTML = highlighted;
        }
    });
}

// Add validation indicators to YAML blocks
function addValidationIndicators(block, validation) {
    // Remove existing indicators
    const existingIndicator = block.parentNode.querySelector('.yaml-validation');
    if (existingIndicator) {
        existingIndicator.remove();
    }
    
    if (validation.errors.length > 0 || validation.warnings.length > 0) {
        const indicator = document.createElement('div');
        indicator.className = 'yaml-validation';
        indicator.style.cssText = `
            position: absolute;
            top: 2.5rem;
            right: 1rem;
            padding: 0.5rem;
            border-radius: 0.375rem;
            font-size: 0.75rem;
            max-width: 300px;
            z-index: 10;
            box-shadow: var(--shadow-md);
        `;
        
        let content = '';
        if (validation.errors.length > 0) {
            indicator.style.background = 'var(--danger-color)';
            indicator.style.color = 'white';
            content += `<strong>❌ ${validation.errors.length} Error(s):</strong><br>`;
            validation.errors.forEach(error => {
                content += `Line ${error.line}: ${error.message}<br>`;
            });
        } else if (validation.warnings.length > 0) {
            indicator.style.background = 'var(--warning-color)';
            indicator.style.color = 'white';
            content += `<strong>⚠️ ${validation.warnings.length} Warning(s):</strong><br>`;
            validation.warnings.forEach(warning => {
                content += `Line ${warning.line}: ${warning.message}<br>`;
            });
        }
        
        if (validation.isValid && validation.warnings.length === 0) {
            indicator.style.background = 'var(--success-color)';
            indicator.style.color = 'white';
            content = '✅ Valid YAML';
        }
        
        indicator.innerHTML = content;
        block.parentNode.appendChild(indicator);
    }
}

// Add format button to YAML blocks
function addFormatButton(block, originalContent, yamlProcessor) {
    const formatButton = document.createElement('button');
    formatButton.className = 'format-btn';
    formatButton.innerHTML = '🔧 Format';
    formatButton.style.cssText = `
        position: absolute;
        top: 0.5rem;
        right: 5rem;
        background: var(--info-color);
        color: white;
        border: none;
        padding: 0.25rem 0.5rem;
        border-radius: 0.25rem;
        font-size: 0.75rem;
        cursor: pointer;
        opacity: 0;
        transition: opacity 0.3s ease;
    `;
    
    block.parentNode.appendChild(formatButton);
    
    block.parentNode.addEventListener('mouseenter', () => {
        formatButton.style.opacity = '1';
    });
    
    block.parentNode.addEventListener('mouseleave', () => {
        formatButton.style.opacity = '0';
    });
    
    formatButton.addEventListener('click', () => {
        const formatted = yamlProcessor.formatYaml(originalContent);
        const validation = yamlProcessor.parseYaml(formatted);
        const highlighted = yamlProcessor.highlightYaml(formatted);
        
        block.innerHTML = highlighted;
        addValidationIndicators(block, validation);
        
        formatButton.innerHTML = '✅ Formatted!';
        setTimeout(() => {
            formatButton.innerHTML = '🔧 Format';
        }, 2000);
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
