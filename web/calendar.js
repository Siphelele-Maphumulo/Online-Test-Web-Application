
function initializeCalendar(calendarData) {
    try {
        const calendarEl = document.getElementById('calendar-container');
        if (!calendarEl) {
            console.error('Calendar container not found.');
            return;
        }

        const calendar = new VanillaJsCalendar(calendarEl, {
            events: calendarData,
            settings: {
                range: {
                    start: new Date(new Date().getFullYear(), new Date().getMonth() - 2, 1),
                    end: new Date(new Date().getFullYear(), new Date().getMonth() + 3, 0)
                },
                visibility: {
                    daysOutside: false,
                    weekend: true
                },
                lang: 'en'
            },
        });
    } catch (error) {
        console.error('Error initializing calendar:', error);
        const calendarContainer = document.getElementById('calendar-container');
        if (calendarContainer) {
            calendarContainer.innerHTML =
                '<div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Could not load calendar. Please try again later.</div>';
        }
    }
}
