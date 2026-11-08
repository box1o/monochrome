.pragma library

function month(today, offset) {
    return new Date(today.getFullYear(), today.getMonth() + offset, 1, 12);
}

function cells(today, displayed) {
    const leading = (displayed.getDay() + 6) % 7;
    return Array.from({ length: 42 }, (_, index) => {
        const date = new Date(displayed.getFullYear(), displayed.getMonth(), 1 - leading + index, 12);
        return {
            date: date,
            day: date.getDate(),
            inMonth: date.getMonth() === displayed.getMonth(),
            isToday: date.getFullYear() === today.getFullYear()
                && date.getMonth() === today.getMonth() && date.getDate() === today.getDate()
        };
    });
}
