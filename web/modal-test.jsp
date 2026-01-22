<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Modal Test</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <jsp:include page="modal_assets.jspf" />
</head>
<body>
    <div style="padding: 20px; text-align: center;">
        <h1>Modal System Test</h1>
        <button onclick="testAlert()">Test Alert Modal</button>
        <button onclick="testConfirm()">Test Confirm Modal</button>
        <button onclick="testDeleteConfirm()">Test Delete Confirm</button>
    </div>

    <script>
        async function testAlert() {
            showAlert('This is a test alert message!', 'Test Alert', 'fa-info-circle');
        }

        async function testConfirm() {
            const result = await showConfirm('Do you want to proceed with this action?', 'Test Confirmation');
            showAlert(`You clicked: ${result ? 'Confirm' : 'Cancel'}`, 'Result');
        }

        async function testDeleteConfirm() {
            const result = await showConfirm('Are you sure you want to delete this question? This action cannot be undone.', 'Delete Question');
            if (result) {
                showAlert('Question would be deleted!', 'Confirmed');
            } else {
                showAlert('Delete cancelled', 'Cancelled');
            }
        }
    </script>
</body>
</html>