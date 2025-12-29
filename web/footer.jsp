<footer class="footer bg-dark text-white py-3">
    <div class="container">
        <div class="row align-items-center">
            
            <!-- Left Column: Company Info -->
            <div class="col-md-4 mb-3 mb-md-0">
                <div class="footer-content">
                    <h5 class="footer-title mb-2" style="color: #FFFFFF; font-size: 1rem;">CodeSA Institute</h5>
                    <ul class="list-unstyled mb-0">
                        <li class="footer-item mb-1 d-flex align-items-center">
                            <i class="fas fa-user-tie me-2" style="color: #FFFFFF; font-size: 0.9rem;"></i>
                            <span style="font-size: 0.9rem; color: #FFFFFF;">Manager: <strong>Mrs. L. Mthethwa</strong></span>
                        </li>
                        <li class="footer-item mb-1 d-flex align-items-center">
                            <i class="fas fa-envelope me-2" style="color: #FFFFFF; font-size: 0.9rem;"></i>
                            <span style="font-size: 0.9rem; color: #FFFFFF;">
                                Email: <a href="mailto:info@codingmadeeasy.org" class="text-white text-decoration-none" style="font-size: 0.9rem;">info@codingmadeeasy.org</a>
                            </span>
                        </li>
                        <li class="footer-item mb-1 d-flex align-items-center">
                            <i class="fas fa-map-marker-alt me-2" style="color: #FFFFFF; font-size: 0.9rem;"></i>
                            <span style="font-size: 0.9rem; color: #FFFFFF;">Durban, South Africa</span>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- Center Column: Logo -->
            <div class="col-md-4 mb-3 mb-md-0">
                <div class="footer-logo-container text-center">
                    <img src="IMG/mut-45yearslogo-whitetrans1024x362-12@2x.png" alt="MUT 45 Years Logo" class="footer-logo img-fluid" style="max-width: 200px; height: auto;">
                    <div class="mt-2">
                        <small style="color: #CCCCCC; font-size: 0.8rem;">Official Partner</small>
                    </div>
                </div>
            </div>

            <!-- Right Column: Developer Info -->
            <div class="col-md-4">
                <div class="footer-content">
                    <h5 class="footer-title mb-2" style="color: #FFFFFF; font-size: 1rem;">Development Team</h5>
                    <ul class="list-unstyled mb-0">
                        <li class="footer-item mb-1 d-flex align-items-center">
                            <i class="fas fa-code me-2" style="color: #FFFFFF; font-size: 0.9rem;"></i>
                            <span style="font-size: 0.9rem; color: #FFFFFF;">Developer: <strong>Maphumulo SA</strong></span>
                        </li>
                        <li class="footer-item mb-1 d-flex align-items-center">
                            <i class="fas fa-phone me-2" style="color: #FFFFFF; font-size: 0.9rem;"></i>
                            <span style="font-size: 0.9rem; color: #FFFFFF;">Tel: <strong>068 676 4623</strong></span>
                        </li>
                        <li class="footer-item mb-1 d-flex align-items-center">
                            <i class="fas fa-fax me-2" style="color: #FFFFFF; font-size: 0.9rem;"></i>
                            <span style="font-size: 0.9rem; color: #FFFFFF;">Fax: <strong>031 907 7655</strong></span>
                        </li>
                        <li class="footer-item mb-1 d-flex align-items-center">
                            <i class="fas fa-envelope me-2" style="color: #FFFFFF; font-size: 0.9rem;"></i>
                            <span style="font-size: 0.9rem; color: #FFFFFF;">
                                Email: <a href="mailto:Siphelelemaphumulo@gmail.com" class="text-white text-decoration-none" style="font-size: 0.9rem;">Siphelelemaphumulo@gmail.com</a>
                            </span>
                        </li>
                    </ul>
                </div>
            </div>

        </div>

        <!-- Copyright / Bottom Row -->
        <div class="row mt-3 pt-2 border-top border-secondary">
            <div class="col-12 text-center">
                <p class="mb-0" style="color: #CCCCCC; font-size: 0.8rem;">
                    <i class="far fa-copyright me-1" style="color: #CCCCCC;"></i> 
                    <span id="currentYear"></span> CodeSA Institute. All rights reserved. 
                    <span class="mx-1">|</span> 
                    <a href="#" class="text-decoration-none" style="color: #CCCCCC; font-size: 0.8rem;">Privacy Policy</a>
                    <span class="mx-1">?</span>
                    <a href="#" class="text-decoration-none" style="color: #CCCCCC; font-size: 0.8rem;">Terms of Service</a>
                </p>
            </div>
        </div>

    </div>
</footer>

<style>
    /* Professional Compact Footer Styling */
    .footer {
        background: #09294D;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }

    .footer-title {
        font-weight: 600;
        letter-spacing: 0.3px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.3);
        padding-bottom: 5px;
        display: inline-block;
    }

    .footer-content {
        padding: 5px 0;
    }

    .footer-item {
        line-height: 1.4;
        transition: all 0.2s ease;
    }

    .footer-item:hover {
        transform: translateX(3px);
    }

    .footer-item i {
        width: 18px;
        text-align: center;
    }

    .footer-logo {
        filter: brightness(0) invert(1);
        opacity: 0.9;
        transition: all 0.2s ease;
    }

    .footer-logo:hover {
        opacity: 1;
        transform: scale(1.03);
    }

    .footer-logo-container {
        padding: 8px 0;
    }

    a:hover {
        color: #4dabf7 !important;
        text-decoration: underline !important;
    }

    .border-secondary {
        border-color: rgba(255, 255, 255, 0.1) !important;
    }

    /* Responsive Adjustments */
    @media (max-width: 768px) {
        .footer {
            text-align: center;
            padding: 1.5rem 0 !important;
        }
        
        .footer-content {
            margin-bottom: 1rem;
        }
        
        .footer-item {
            justify-content: center !important;
        }
        
        .footer-logo {
            max-width: 180px !important;
        }
        
        .footer-title {
            font-size: 1.1rem !important;
        }
        
        .footer-item span {
            font-size: 0.95rem !important;
        }
    }

    @media (max-width: 576px) {
        .footer {
            padding: 1rem 0 !important;
        }
        
        .footer-logo {
            max-width: 150px !important;
        }
        
        .row {
            flex-direction: column;
        }
        
        .col-md-4 {
            margin-bottom: 1.5rem;
        }
        
        .col-md-4:last-child {
            margin-bottom: 0;
        }
    }
</style>

<script>
    // Set current year in copyright
    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('currentYear').textContent = new Date().getFullYear();
        
        // Add smooth hover effect for footer items
        const footerItems = document.querySelectorAll('.footer-item');
        footerItems.forEach(item => {
            item.addEventListener('mouseenter', function() {
                this.style.transform = 'translateX(3px)';
            });
            item.addEventListener('mouseleave', function() {
                this.style.transform = 'translateX(0)';
            });
        });
        
        // Add hover effect for links
        const links = document.querySelectorAll('a');
        links.forEach(link => {
            link.addEventListener('mouseenter', function() {
                this.style.textDecoration = 'underline';
            });
            link.addEventListener('mouseleave', function() {
                this.style.textDecoration = 'none';
            });
        });
    });
</script>