// Drag and Drop functionality
let dragItems = [];
let dropTargets = [];
let correctPairings = {};

function initializeDragDrop() {
    console.log('Initializing drag-drop with JSON data...');
    
    try {
        // Get the raw JSON arrays from the server (passed from JSP)
        console.log('Raw dragItemsFromDB:', window.dragItemsFromDB);
        console.log('Raw dropTargetsFromDB:', window.dropTargetsFromDB);
        console.log('Raw correctTargetsFromDB:', window.correctTargetsFromDB);
        console.log('Raw totalMarksFromDB:', window.totalMarksFromDB);
        
        // Parse the JSON arrays
        const dragItemsArray = JSON.parse(window.dragItemsFromDB || '[]');
        const dropTargetsArray = JSON.parse(window.dropTargetsFromDB || '[]');
        const correctTargetsArray = JSON.parse(window.correctTargetsFromDB || '[]');
        
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
        
        // Set total marks if available
        if (window.totalMarksFromDB && document.getElementById('totalMarksInput')) {
            document.getElementById('totalMarksInput').value = window.totalMarksFromDB;
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
}

function removeDragItem(id) {
    dragItems = dragItems.filter(item => item.id !== id);
    delete correctPairings[id];
    renderDragItems();
}

function removeDropTarget(id) {
    dropTargets = dropTargets.filter(target => target.id !== id);
    Object.keys(correctPairings).forEach(dragId => {
        if (correctPairings[dragId] === id) {
            delete correctPairings[dragId];
        }
    });
    renderDropTargets();
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
    const container = document.getElementById('draggableItemsList');
    if (!container) {
        console.error('draggableItemsList container not found');
        return;
    }
    container.innerHTML = '';
    
    dragItems.forEach(item => {
        const div = document.createElement('div');
        div.className = 'form-group';
        div.style.cssText = 'display: flex; gap: 10px; align-items: center; background: var(--light-gray); padding: 10px; border-radius: 4px;';
        div.innerHTML = `
            <span style="font-weight: bold; color: var(--primary-blue);">ID: ${item.id}</span>
            <input type="text" class="form-control dnd-item-text" placeholder="Display Text" value="${escapeHtml(item.text)}" oninput="updateDragItem(${item.id}, this.value)">
            <button type="button" class="btn btn-outline" style="color: var(--error); padding: 5px 10px;" onclick="removeDragItem(${item.id})">
                <i class="fas fa-trash"></i>
            </button>
        `;
        container.appendChild(div);
    });
    
    updateHiddenFields();
}

function renderDropTargets() {
    const container = document.getElementById('dropZonesList');
    if (!container) {
        console.error('dropZonesList container not found');
        return;
    }
    container.innerHTML = '';
    
    dropTargets.forEach(target => {
        const div = document.createElement('div');
        div.className = 'form-group';
        div.style.cssText = 'display: flex; flex-direction: column; gap: 5px; background: var(--light-gray); padding: 10px; border-radius: 4px; border-left: 3px solid var(--accent-blue);';
        div.innerHTML = `
            <div style="display: flex; gap: 10px; align-items: center;">
                <input type="text" class="form-control dnd-zone-label" placeholder="Zone Label (e.g. Target A)" value="${escapeHtml(target.text)}" onchange="updateDropTarget(${target.id}, this.value)">
                <button type="button" class="btn btn-outline" style="color: var(--error); padding: 5px 10px;" onclick="removeDropTarget(${target.id})">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
            <div style="display: flex; gap: 10px; align-items: center; margin-top: 5px;">
                <small style="font-weight: 600;">Correct Item:</small>
                <select class="form-select dnd-zone-correct" style="padding: 4px 8px; font-size: 12px; margin-bottom: 0;" onchange="updatePairingForTarget(${target.id}, this.value)">
                    <option value="">Select Correct Item</option>
                    ${dragItems.map(item => {
                        const isSelected = correctPairings[item.id] === target.id ? 'selected' : '';
                        return `<option value="${item.id}" ${isSelected}>ID ${item.id}: ${escapeHtml(item.text)}</option>`;
                    }).join('')}
                </select>
            </div>
        `;
        container.appendChild(div);
    });
    
    updateHiddenFields();
}

function renderPairings() {
    // Since the current UI structure handles pairings within the drop targets,
    // this function can be simplified or removed
    // The pairings are already rendered in renderDropTargets()
    console.log('Pairings are rendered within drop targets');
}

function updatePairingForTarget(targetId, dragItemId) {
    // Remove any existing pairing for this target
    Object.keys(correctPairings).forEach(key => {
        if (correctPairings[key] === parseInt(targetId)) {
            delete correctPairings[key];
        }
    });
    
    // Add the new pairing if a drag item was selected
    if (dragItemId) {
        correctPairings[parseInt(dragItemId)] = parseInt(targetId);
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
    
    // Store as JSON strings in the hidden fields
    const dragItemsHidden = document.getElementById('dragItemsData');
    const dropTargetsHidden = document.getElementById('dropTargetsData');
    const correctTargetsHidden = document.getElementById('dragCorrectTargetsData');
    
    if (dragItemsHidden) dragItemsHidden.value = JSON.stringify(dragItemTexts);
    if (dropTargetsHidden) dropTargetsHidden.value = JSON.stringify(dropTargetTexts);
    if (correctTargetsHidden) correctTargetsHidden.value = JSON.stringify(correctTargetTexts);
    
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
