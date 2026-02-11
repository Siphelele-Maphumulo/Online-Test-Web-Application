// Drag and Drop functionality
let dragItems = [];
let dropTargets = [];
let correctPairings = {};

// Global variables to hold JSP data
let dragItemsJson = '[]';
let dropTargetsJson = '[]';
let dragCorrectTargetsJson = '[]';

function initializeDragDrop() {
    console.log('Initializing drag-drop with relational data...');
    
    try {
        // Get the raw JSON strings from the server (passed from JSP)
        console.log('Raw dragItems:', dragItemsJson);
        console.log('Raw dropTargets:', dropTargetsJson);
        console.log('Raw correctTargets:', dragCorrectTargetsJson);
        
        // Parse the JSON arrays
        const dragItemsArray = JSON.parse(dragItemsJson);
        const dropTargetsArray = JSON.parse(dropTargetsJson);
        const correctTargetsArray = JSON.parse(dragCorrectTargetsJson);
        
        // Convert drag items from string array to object array
        dragItems = dragItemsArray.map((text, index) => {
            // Remove surrounding quotes if present
            let cleanText = text;
            if (typeof text === 'string') {
                cleanText = text.replace(/^"|"$/g, '');
            }
            return {
                id: index + 1,
                text: cleanText
            };
        });
        
        // Convert drop targets from string array to object array
        dropTargets = dropTargetsArray.map((text, index) => {
            // Remove surrounding quotes if present
            let cleanText = text;
            if (typeof text === 'string') {
                cleanText = text.replace(/^"|"$/g, '');
            }
            return {
                id: index + 1,
                text: cleanText
            };
        });
        
        // Convert correct pairings - this is a string array where each index
        // corresponds to the drag item at the same index, and the value is the target text
        correctPairings = {};
        
        // Only process if we have valid data
        if (correctTargetsArray && correctTargetsArray.length > 0) {
            correctTargetsArray.forEach((targetText, index) => {
                if (index < dragItems.length && targetText) {
                    // Clean the target text
                    let cleanTargetText = targetText;
                    if (typeof targetText === 'string') {
                        cleanTargetText = targetText.replace(/^"|"$/g, '');
                    }
                    
                    // Find the target ID that matches this target text
                    const targetIndex = dropTargets.findIndex(t => t.text === cleanTargetText);
                    if (targetIndex !== -1) {
                        correctPairings[dragItems[index].id] = dropTargets[targetIndex].id;
                    }
                }
            });
        }
        
        console.log('Parsed dragItems:', dragItems);
        console.log('Parsed dropTargets:', dropTargets);
        console.log('Parsed correctPairings:', correctPairings);
        
    } catch (e) {
        console.error('Error parsing drag-drop data:', e);
        dragItems = [];
        dropTargets = [];
        correctPairings = {};
    }
    
    // If no items exist, add one empty item
    if (dragItems.length === 0) {
        addDragItem();
    }
    
    // If no targets exist, add one empty target
    if (dropTargets.length === 0) {
        addDropTarget();
    }
    
    // Render the UI
    renderDragItems();
    renderDropTargets();
    renderPairings();
}

function addDragItem() {
    const id = Date.now();
    dragItems.push({ id, text: '' });
    renderDragItems();
}

function addDropTarget() {
    const id = Date.now();
    dropTargets.push({ id, text: '' });
    renderDropTargets();
    renderPairings();
}

function removeDragItem(id) {
    dragItems = dragItems.filter(item => item.id !== id);
    delete correctPairings[id];
    renderDragItems();
    renderPairings();
}

function removeDropTarget(id) {
    dropTargets = dropTargets.filter(target => target.id !== id);
    Object.keys(correctPairings).forEach(dragId => {
        if (correctPairings[dragId] === id) {
            delete correctPairings[dragId];
        }
    });
    renderDropTargets();
    renderPairings();
}

function updateDragItem(id, text) {
    const item = dragItems.find(item => item.id === id);
    if (item) {
        item.text = text;
    }
}

function updateDropTarget(id, text) {
    const target = dropTargets.find(target => target.id === id);
    if (target) {
        target.text = text;
    }
}

function renderDragItems() {
    const container = document.getElementById('dragItemsList');
    container.innerHTML = '';
    
    dragItems.forEach(item => {
        const div = document.createElement('div');
        div.className = 'drag-item';
        div.innerHTML = '<i class="fas fa-grip-lines drag-handle"></i>' +
            '<input type="text" value="' + escapeHtml(item.text) + '" placeholder="Enter drag item text" ' +
                   'onchange="updateDragItem(' + item.id + ', this.value)">' +
            '<button type="button" class="remove-btn" onclick="removeDragItem(' + item.id + ')">×</button>';
        container.appendChild(div);
    });
    
    updateHiddenFields();
}

function renderDropTargets() {
    const container = document.getElementById('dropTargetsList');
    container.innerHTML = '';
    
    dropTargets.forEach(target => {
        const div = document.createElement('div');
        div.className = 'drop-target';
        div.innerHTML = '<i class="fas fa-bullseye"></i>' +
            '<input type="text" value="' + escapeHtml(target.text) + '" placeholder="Enter drop target text" ' +
                   'onchange="updateDropTarget(' + target.id + ', this.value)">' +
            '<button type="button" class="remove-btn" onclick="removeDropTarget(' + target.id + ')">×</button>';
        container.appendChild(div);
    });
    
    updateHiddenFields();
}

function renderPairings() {
    const container = document.getElementById('pairingsList');
    container.innerHTML = '';
    
    dropTargets.forEach(target => {
        const div = document.createElement('div');
        div.className = 'pairing-item';
        
        // Find which drag item is paired with this target
        let pairedDragId = null;
        for (const [dragId, targetId] of Object.entries(correctPairings)) {
            if (targetId === target.id) {
                pairedDragId = parseInt(dragId);
                break;
            }
        }
        
        div.innerHTML = '<i class="fas fa-link"></i>' +
            '<span>' + escapeHtml(target.text || 'Target ' + target.id) + '</span>' +
            '<select class="pairing-select" onchange="updatePairingForTarget(' + target.id + ', this.value)">' +
                '<option value="">None</option>' +
                dragItems.map(item => {
                    const selected = (pairedDragId === item.id) ? ' selected' : '';
                    return '<option value="' + item.id + '"' + selected + '>' + 
                           escapeHtml(item.text || 'Item ' + item.id) + '</option>';
                }).join('') +
            '</select>';
        container.appendChild(div);
    });
}

function updatePairingForTarget(targetId, dragItemId) {
    // Remove any existing pairing for this target
    Object.keys(correctPairings).forEach(key => {
        if (correctPairings[key] === targetId) {
            delete correctPairings[key];
        }
    });
    
    // Add the new pairing if a drag item was selected
    if (dragItemId) {
        correctPairings[dragItemId] = parseInt(targetId);
    }
    
    updateHiddenFields();
}

function updateHiddenFields() {
    // Convert objects back to arrays of strings for storage
    const dragItemTexts = dragItems.map(item => item.text);
    const dropTargetTexts = dropTargets.map(target => target.text);
    
    // Create correct targets array (target text for each drag item)
    const correctTargetTexts = dragItems.map(item => {
        const targetId = correctPairings[item.id];
        if (targetId) {
            const target = dropTargets.find(t => t.id === targetId);
            return target ? target.text : '';
        }
        return '';
    });
    
    // Store as JSON strings
    document.getElementById('dragItemsData').value = JSON.stringify(dragItemTexts);
    document.getElementById('dropTargetsData').value = JSON.stringify(dropTargetTexts);
    document.getElementById('dragCorrectTargetsData').value = JSON.stringify(correctTargetTexts);
    
    console.log('Storing drag items:', dragItemTexts);
    console.log('Storing drop targets:', dropTargetTexts);
    console.log('Storing correct targets:', correctTargetTexts);
}

// Helper function to escape HTML
function escapeHtml(text) {
    if (!text) return '';
    return String(text)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}
