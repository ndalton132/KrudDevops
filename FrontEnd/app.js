// API base URL - your backend server
const API_URL = '/api/todos';

// Get references to HTML elements
const todoInput = document.getElementById('todoInput');
const addBtn = document.getElementById('addBtn');
const todoList = document.getElementById('todoList');
const loading = document.getElementById('loading');
const error = document.getElementById('error');
const totalCount = document.getElementById('totalCount');
const completedCount = document.getElementById('completedCount');

// Store todos in memory for easy access
let todos = [];

// Initialize app when page loads
document.addEventListener('DOMContentLoaded', () => {
    loadTodos();
    setupEventListeners();
});

// Set up event listeners
function setupEventListeners() {
    // Add todo when button is clicked
    addBtn.addEventListener('click', addTodo);
    
    // Add todo when Enter key is pressed
    todoInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            addTodo();
        }
    });
}

// Show/hide loading indicator
function showLoading(show) {
    loading.classList.toggle('hidden', !show);
}

// Show error message
function showError(message) {
    error.textContent = message;
    error.classList.remove('hidden');
    setTimeout(() => {
        error.classList.add('hidden');
    }, 5000);
}

// Update stats (total and completed count)
function updateStats() {
    const total = todos.length;
    const completed = todos.filter(todo => todo.completed).length;
    
    totalCount.textContent = `Total: ${total}`;
    completedCount.textContent = `Completed: ${completed}`;
}

// FETCH ALL TODOS FROM API
async function loadTodos() {
    showLoading(true);
    
    try {
        const response = await fetch(API_URL);
        
        if (!response.ok) {
            throw new Error('Failed to fetch todos');
        }
        
        const data = await response.json();
        todos = data.data;
        
        renderTodos();
        updateStats();
        
    } catch (err) {
        console.error('Error loading todos:', err);
        showError('Failed to load todos. Is your server running?');
    } finally {
        showLoading(false);
    }
}

// CREATE NEW TODO
async function addTodo() {
    const title = todoInput.value.trim();
    
    if (!title) {
        showError('Please enter a todo title');
        return;
    }
    
    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ title })
        });
        
        if (!response.ok) {
            throw new Error('Failed to create todo');
        }
        
        const data = await response.json();
        todos.push(data.data);
        todoInput.value = '';
        
        renderTodos();
        updateStats();
        
    } catch (err) {
        console.error('Error adding todo:', err);
        showError('Failed to add todo');
    }
}

// UPDATE TODO (mark as complete/incomplete)
async function toggleTodo(id, currentStatus) {
    try {
        const response = await fetch(`${API_URL}/${id}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ completed: !currentStatus })
        });
        
        if (!response.ok) {
            throw new Error('Failed to update todo');
        }
        
        const data = await response.json();
        const index = todos.findIndex(todo => todo.id === id);
        if (index !== -1) {
            todos[index] = data.data;
        }
        
        renderTodos();
        updateStats();
        
    } catch (err) {
        console.error('Error updating todo:', err);
        showError('Failed to update todo');
    }
}

// DELETE TODO
async function deleteTodo(id) {
    if (!confirm('Are you sure you want to delete this todo?')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_URL}/${id}`, {
            method: 'DELETE'
        });
        
        if (!response.ok) {
            throw new Error('Failed to delete todo');
        }
        
        todos = todos.filter(todo => todo.id !== id);
        
        renderTodos();
        updateStats();
        
    } catch (err) {
        console.error('Error deleting todo:', err);
        showError('Failed to delete todo');
    }
}

// RENDER TODOS ON SCREEN
function renderTodos() {
    todoList.innerHTML = '';
    
    if (todos.length === 0) {
        todoList.innerHTML = `
            <div class="empty-state">
                <h3>No todos yet!</h3>
                <p>Add your first todo above to get started.</p>
            </div>
        `;
        return;
    }
    
    todos.forEach(todo => {
        const todoItem = createTodoElement(todo);
        todoList.appendChild(todoItem);
    });
}

// CREATE HTML ELEMENT FOR A SINGLE TODO
function createTodoElement(todo) {
    const div = document.createElement('div');
    div.className = `todo-item ${todo.completed ? 'completed' : ''}`;
    
    const date = new Date(todo.created_at);
    const formattedDate = date.toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric'
    });
    
    div.innerHTML = `
        <input 
            type="checkbox" 
            class="todo-checkbox" 
            ${todo.completed ? 'checked' : ''}
            onchange="toggleTodo(${todo.id}, ${todo.completed})"
        >
        <span class="todo-text">${escapeHtml(todo.title)}</span>
        <span class="todo-date">${formattedDate}</span>
        <button 
            class="btn btn-danger" 
            onclick="deleteTodo(${todo.id})"
        >
            Delete
        </button>
    `;
    
    return div;
}

// Escape HTML to prevent XSS attacks
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}