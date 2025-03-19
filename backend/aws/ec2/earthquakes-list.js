class Node {
    constructor(key, value) {
        this.key = key;
        this.details = value;
        this.prev = null;
        this.next = null;
    }
}

class EarthquakesList {
    constructor(maxSize) {
        this.maxSize = maxSize;
        this.size = 0;
        this.head = null;
        this.tail = null;
    }

    add(key, value) {
        let existingNode = this.findNodeByKey(key);
        if (existingNode) {
            existingNode.details = value; // Update existing node
            return;
        }

        const newNode = new Node(key, value);

        // If the list is empty, set the new node as head and tail
        if (!this.head) {
            this.head = this.tail = newNode;
        } else {
            // Insert in sorted order (newest first)
            let current = this.head;
            while (current && new Date(value.data.properties.time) < new Date(current.details.data.properties.time)) {
                current = current.next;
            }

            if (!current) {
                // Append at the end (oldest)
                this.tail.next = newNode;
                newNode.prev = this.tail;
                this.tail = newNode;
            } else if (current === this.head) {
                // Insert at the beginning (newest)
                newNode.next = this.head;
                this.head.prev = newNode;
                this.head = newNode;
            } else {
                // Insert in the middle
                newNode.prev = current.prev;
                newNode.next = current;
                current.prev.next = newNode;
                current.prev = newNode;
            }
        }

        this.size++;

        // Maintain max size of 100 by removing the oldest (tail) if necessary
        if (this.size > this.maxSize) {
            this.removeTail();
        }
    }

    remove(key) {
        const nodeToRemove = this.findNodeByKey(key);
        if (!nodeToRemove) return false;

        if (nodeToRemove === this.head) {
            this.head = nodeToRemove.next;
            if (this.head) this.head.prev = null;
        } else if (nodeToRemove === this.tail) {
            this.tail = nodeToRemove.prev;
            if (this.tail) this.tail.next = null;
        } else {
            nodeToRemove.prev.next = nodeToRemove.next;
            nodeToRemove.next.prev = nodeToRemove.prev;
        }

        this.size--;
        return true;
    }

    find(key) {
        const node = this.findNodeByKey(key);
        return node ? node.details : null;
    }

    findNodeByKey(key) {
        let current = this.head;
        while (current) {
            if (current.key === key) return current;
            current = current.next;
        }
        return null;
    }

    removeTail() {
        if (!this.tail) return;

        if (this.tail === this.head) {
            this.head = this.tail = null;
        } else {
            this.tail = this.tail.prev;
            this.tail.next = null;
        }

        this.size--;
    }

    // Function to print all keys in the list
    printKeys() {
        let current = this.head;
        let keys = [];
        while (current) {
            keys.push(current.key);
            current = current.next;
        }
        console.log("Keys in the list:", keys.join(" -> "));
    }

    // Function to convert the list to an array of objects
    toObject() {
        let current = this.head;
        const listArray = [];
        while (current) {
            listArray.push({ key: current.key, details: current.details });
            current = current.next;
        }
        return listArray;
    }

    // Method to convert the list to a JSON string
    toJSONString() {
        return JSON.stringify(this.toObject());
    }
}

module.exports = EarthquakesList;
