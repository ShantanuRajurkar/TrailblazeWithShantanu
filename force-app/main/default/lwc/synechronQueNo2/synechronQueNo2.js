import { LightningElement } from 'lwc';

export default class ImageEditor extends LightningElement {
    imageLoaded = false;
    imageSrc = '';
    isEditing = false;  // Track if image is being edited
    offsetX = 0;
    offsetY = 0;
    originalWidth = 0;
    originalHeight = 0;
    isResizing = false;

    generateBlock() {
        // Trigger the loading of an image
        this.imageSrc = 'https://images.pexels.com/photos/1666021/pexels-photo-1666021.jpeg?cs=srgb&dl=conifers-daylight-environment-1666021.jpg&fm=jpg'; // Replace with actual image URL
        this.imageLoaded = true;
    }

    killBlock() {
        // Remove the image from the screen
        this.imageLoaded = false;
    }

    editBlock() {
        // Enable resizing of the image
        this.isEditing = true;
        const image = this.template.querySelector('img');
        image.classList.add('editing');  // Add the resizing cursor to indicate editing
    }

    onImageMouseDown(event) {
        if (this.isEditing) {
            this.isResizing = true;
            this.offsetX = event.clientX;
            this.offsetY = event.clientY;
            this.originalWidth = event.target.width;
            this.originalHeight = event.target.height;

            // Listen for mouse move and mouse up
            document.addEventListener('mousemove', this.onImageMouseMove);
            document.addEventListener('mouseup', this.onImageMouseUp);
        }
    }

    onImageMouseMove(event) {
        if (this.isResizing) {
            let widthChange = event.clientX - this.offsetX;
            let heightChange = event.clientY - this.offsetY;
            let newWidth = this.originalWidth + widthChange;
            let newHeight = this.originalHeight + heightChange;

            const image = this.template.querySelector('img');
            image.width = newWidth;
            image.height = newHeight;
        }
    }

    onImageMouseUp() {
        // End resizing when the mouse is released
        this.isResizing = false;
        const image = this.template.querySelector('img');
        image.classList.remove('editing');  // Remove the editing cursor
        document.removeEventListener('mousemove', this.onImageMouseMove);
        document.removeEventListener('mouseup', this.onImageMouseUp);
    }
}
