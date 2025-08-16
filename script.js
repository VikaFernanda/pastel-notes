document.addEventListener('DOMContentLoaded', () => {
    const noteInput = document.getElementById('note-input');
    const addNoteBtn = document.getElementById('add-note-btn');
    const notesContainer = document.getElementById('notes-container');

    // Load notes from local storage when the page loads
    loadNotes();

    // Event listener for the "Add Note" button
    addNoteBtn.addEventListener('click', addNote);

    // Allow adding notes by pressing "Enter"
    noteInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault(); // Prevents new line on Enter
            addNote();
        }
    });

    function addNote() {
        const noteText = noteInput.value.trim();
        if (noteText === '') {
            alert("Please write something in your note!");
            return;
        }

        createNoteElement(noteText);
        saveNotes();

        noteInput.value = ''; // Clear the textarea
        noteInput.focus();
    }

    function createNoteElement(text) {
        // Create the main note div
        const noteDiv = document.createElement('div');
        noteDiv.classList.add('note');
        noteDiv.textContent = text;

        // Create the delete button
        const deleteBtn = document.createElement('button');
        deleteBtn.classList.add('delete-btn');
        deleteBtn.innerHTML = '&times;'; // '×' symbol

        // Add event listener to delete the note
        deleteBtn.addEventListener('click', (e) => {
            e.stopPropagation(); // Prevent other events from firing
            notesContainer.removeChild(noteDiv);
            saveNotes(); // Update local storage after deleting
        });

        noteDiv.appendChild(deleteBtn);
        notesContainer.appendChild(noteDiv);
    }

    function saveNotes() {
        const notes = [];
        // Select all note divs, get their text content
        document.querySelectorAll('.note').forEach(note => {
            // Get only the text of the note itself, excluding the delete button's text
            const text = Array.from(note.childNodes)
                .find(node => node.nodeType === Node.TEXT_NODE)
                .textContent.trim();
            notes.push(text);
        });
        // Store the array of notes as a JSON string
        localStorage.setItem('pastelNotes', JSON.stringify(notes));
    }

    function loadNotes() {
        const notes = JSON.parse(localStorage.getItem('pastelNotes'));
        if (notes) {
            notes.forEach(noteText => createNoteElement(noteText));
        }
    }
});