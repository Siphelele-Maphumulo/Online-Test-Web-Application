/**
 * Drag and Drop Edit UI Logic
 * Standardized according to technical requirements.
 */

document.addEventListener("DOMContentLoaded", function () {
    // 🔹 STEP 4 — On Page Load, Auto-Populate UI
    if (typeof dragItemsFromDB !== "undefined" && dragItemsFromDB !== null) {
        populateDragItems(dragItemsFromDB);
        populateDropTargets(dropTargetsFromDB);
        populateCorrectPairings(
            dragItemsFromDB,
            dropTargetsFromDB,
            correctTargetsFromDB
        );

        const marksInput = document.getElementById("totalMarksInput");
        if (marksInput && typeof totalMarksFromDB !== "undefined") {
            marksInput.value = totalMarksFromDB;
        }
    }
});

// 🔹 STEP 5 — Populate Draggable Items Section
function populateDragItems(items) {
    const container = document.getElementById("dragItemsContainer");
    if (!container) return;
    container.innerHTML = "";

    if (items && items.length > 0) {
        items.forEach(item => {
            addDragItemToUI(item);
        });
    } else {
        // Show empty state if needed or add one empty item
        container.innerHTML = '<div class="empty-state"><i class="fas fa-grip-vertical"></i><p>No draggable items yet</p></div>';
    }
    updateItemCounts();
}

function addDragItem() {
    addDragItemToUI("");
    updateCorrectPairingsUI();
}

function addDragItemToUI(itemText) {
    const container = document.getElementById("dragItemsContainer");
    if (!container) return;
    
    // Remove empty state if present
    const emptyState = container.querySelector(".empty-state");
    if (emptyState) emptyState.remove();

    const div = document.createElement("div");
    div.className = "drag-item";
    div.innerHTML = `
        <i class="fas fa-grip-vertical"></i>
        <input type="text" class="form-control" value="${escapeHtml(itemText)}" placeholder="Item text..." oninput="updateCorrectPairingsUI()">
        <button type="button" class="remove-btn" onclick="removeItem(this)">×</button>
    `;
    container.appendChild(div);
    updateItemCounts();
}

// 🔹 STEP 6 — Populate Drop Targets Section
function populateDropTargets(targets) {
    const container = document.getElementById("dropTargetsContainer");
    if (!container) return;
    container.innerHTML = "";

    if (targets && targets.length > 0) {
        targets.forEach(target => {
            addDropTargetToUI(target);
        });
    } else {
        container.innerHTML = '<div class="empty-state"><i class="fas fa-bullseye"></i><p>No drop targets yet</p></div>';
    }
    updateItemCounts();
}

function addDropTarget() {
    addDropTargetToUI("");
    updateCorrectPairingsUI();
    updateDragDropMarks();
}

function addDropTargetToUI(targetText) {
    const container = document.getElementById("dropTargetsContainer");
    if (!container) return;

    // Remove empty state if present
    const emptyState = container.querySelector(".empty-state");
    if (emptyState) emptyState.remove();

    const div = document.createElement("div");
    div.className = "drop-target";
    div.innerHTML = `
        <i class="fas fa-bullseye"></i>
        <input type="text" class="form-control" value="${escapeHtml(targetText)}" placeholder="Target label..." oninput="updateCorrectPairingsUI()">
        <button type="button" class="remove-btn" onclick="removeItem(this)">×</button>
    `;
    container.appendChild(div);
    updateItemCounts();
}

// 🔹 STEP 7 — Populate Correct Pairings
function populateCorrectPairings(items, targets, correctTargets) {
    const container = document.getElementById("correctPairingsContainer");
    if (!container) return;
    container.innerHTML = "";

    items.forEach((item, index) => {
        const correctTarget = correctTargets[index];
        createPairingRow(item, targets, correctTarget);
    });
    updateItemCounts();
}

// 🔹 STEP 8 — Ensure Dropdown Selects Correct Target
function createPairingRow(item, targets, selectedTarget) {
    const container = document.getElementById("correctPairingsContainer");
    if (!container) return;

    // Remove empty state if present
    const emptyState = container.querySelector(".empty-state");
    if (emptyState) emptyState.remove();

    const div = document.createElement("div");
    div.className = "pairing-item";
    
    const itemLabel = document.createElement("span");
    itemLabel.className = "pairing-drag-item-text";
    itemLabel.textContent = item || "(empty item)";
    
    const arrow = document.createElement("i");
    arrow.className = "fas fa-long-arrow-alt-right mx-2";
    arrow.style.color = "var(--dark-gray)";

    const select = document.createElement("select");
    select.className = "pairing-select";
    
    // Add default empty option
    const defaultOpt = document.createElement("option");
    defaultOpt.value = "";
    defaultOpt.textContent = "-- Select Target --";
    select.appendChild(defaultOpt);

    targets.forEach(target => {
        const option = document.createElement("option");
        option.value = target;
        option.textContent = target || "(empty target)";

        if (target === selectedTarget && target !== "") {
            option.selected = true;
        }

        select.appendChild(option);
    });

    div.appendChild(itemLabel);
    div.appendChild(arrow);
    div.appendChild(select);
    container.appendChild(div);
}

/**
 * Re-renders the Correct Pairings UI based on current items and targets
 * preserving existing selections where possible.
 */
function updateCorrectPairingsUI() {
    const items = collectDragItemsFromUI();
    const targets = collectDropTargetsFromUI();
    
    // Collect current selections
    const currentPairingItems = document.querySelectorAll("#correctPairingsContainer .pairing-item");
    const currentSelections = Array.from(currentPairingItems).map(row => {
        return row.querySelector("select").value;
    });

    const container = document.getElementById("correctPairingsContainer");
    container.innerHTML = "";

    items.forEach((item, index) => {
        // Restore selection if it exists and still valid
        const previousSelection = currentSelections[index] || "";
        createPairingRow(item, targets, previousSelection);
    });
    
    updateItemCounts();
}

function removeItem(btn) {
    const item = btn.closest(".drag-item, .drop-target");
    if (item) {
        const isTarget = item.classList.contains("drop-target");
        item.remove();
        updateCorrectPairingsUI();
        if (isTarget) {
            updateDragDropMarks();
        }
    }
}

function updateDragDropMarks() {
    const targetCount = document.querySelectorAll("#dropTargetsContainer .drop-target").length;
    const totalMarksInput = document.getElementById("totalMarksInput");
    if (totalMarksInput) {
        totalMarksInput.value = Math.max(1, targetCount);
    }
}

// 🔹 STEP 9 — When Saving (Convert Back to JSON)
function prepareDragDropDataForSubmit() {
    const dragItems = collectDragItemsFromUI();
    const dropTargets = collectDropTargetsFromUI();
    const correctTargets = collectCorrectPairingsFromUI();

    document.getElementById("dragItemsHidden").value = JSON.stringify(dragItems);
    document.getElementById("dropTargetsHidden").value = JSON.stringify(dropTargets);
    document.getElementById("correctTargetsHidden").value = JSON.stringify(correctTargets);
    
    console.log("Data prepared for submit:", {
        dragItems,
        dropTargets,
        correctTargets
    });
}

function collectDragItemsFromUI() {
    const inputs = document.querySelectorAll("#dragItemsContainer input[type='text']");
    return Array.from(inputs).map(input => input.value.trim());
}

function collectDropTargetsFromUI() {
    const inputs = document.querySelectorAll("#dropTargetsContainer input[type='text']");
    return Array.from(inputs).map(input => input.value.trim());
}

function collectCorrectPairingsFromUI() {
    const selects = document.querySelectorAll("#correctPairingsContainer select.pairing-select");
    return Array.from(selects).map(select => select.value);
}

function updateItemCounts() {
    const dragCount = document.getElementById("dragItemCount");
    const targetCount = document.getElementById("dropTargetCount");
    const pairingCount = document.getElementById("pairingCount");
    
    if (dragCount) dragCount.textContent = collectDragItemsFromUI().length;
    if (targetCount) targetCount.textContent = collectDropTargetsFromUI().length;
    if (pairingCount) pairingCount.textContent = document.querySelectorAll("#correctPairingsContainer .pairing-item").length;
}

function escapeHtml(text) {
    if (!text) return "";
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

// Initialize drag drop if called (for compatibility with edit_question.jsp)
function initializeDragDrop() {
    console.log("initializeDragDrop called manually");
    // DOMContentLoaded logic will also run, but this ensures it's ready if type is switched
    if (typeof dragItemsFromDB !== "undefined") {
        populateDragItems(dragItemsFromDB);
        populateDropTargets(dropTargetsFromDB);
        populateCorrectPairings(
            dragItemsFromDB,
            dropTargetsFromDB,
            correctTargetsFromDB
        );
    }
}
