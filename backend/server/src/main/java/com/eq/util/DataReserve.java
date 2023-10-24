package com.eq.util;
import com.eq.serialized.earthquake.Earthquake;
import org.bson.Document;

import javax.print.Doc;


public class DataReserve {
    //TODO: Store recent 100 eq's
    public static class DoublyLinkedList {

        private int size = 0;
        private int capacity = 100;

        private static DoublyLinkedList instance;

        private Node head;
        private Node tail;

        private class Node {
            Earthquake data;
            Node next;
            Node prev;

            public Node(Earthquake data) {
                this.data = data;
            }
        }

        private DoublyLinkedList() {
            this.head = null;
            this.tail = null;
            this.size = 0;
        }

        public static DoublyLinkedList getInstance() {
            if (instance == null) {
                instance = new DoublyLinkedList();
            }
            return instance;
        }

        public void addToFront(Earthquake data) {
            Node newNode = new Node(data);

            if (size < capacity) {
                if (size == 0) {
                    head = tail = newNode;
                } else {
                    Node temp = head;
                    head = newNode;
                    head.next = temp;
                    temp.prev = head;
                }
                size++;
            } else {
                // Remove the old tail
                tail = tail.prev;
                tail.next = null;

                // Add the new node to the front
                Node temp = head;
                head = newNode;
                head.next = temp;
                temp.prev = head;
            }
        }

        public void add(Earthquake data) {
            if (size < capacity) {
                Node newNode = new Node(data);
                if (size == 0) {
                    head = tail = newNode;
                } else {
                    tail.next = newNode;
                    newNode.prev = tail;
                    tail = newNode;
                }
                size++;
            } else {
                removeFirst();
                add(data);
            }
        }

        public void removeFirst() {
            if (size == 0) {
                return;
            }

            if (size == 1) {
                head = tail = null;
            } else {
                head = head.next;
                head.prev = null;
            }
            size--;
        }


        public boolean replace(int indexToReplace, Earthquake eq) {

            Node temp = head;
            int index = 0;
            if (temp == null) {
                return false;
            }
            else if (temp != null && index == indexToReplace) {
                temp.data = eq;
                return true;
            }
            else {
                return replace(indexToReplace, ++index, temp.next, eq);
            }
        }

        private boolean replace(int indexToReplace, int currentIndex, Node node, Earthquake eq) {

            if (node == null) {
                return false;
            }
            else if (node != null && currentIndex == indexToReplace) {
                node.data = eq;
                return true;
            }
            else {
                return replace(indexToReplace, ++currentIndex, node, eq);
            }
        }

        public int find(String id) {
            Node temp = head;
            int index = 0;
            if (temp != null && temp.data.getData().getId().equals(id)) {
                return 0;
            }
            else {
                return find(id, temp.next, ++index);
            }
        }

        private int find(String id, Node node, int index) {
            if (node == null) {
                return -1;
            }
            else if (node.data.getData().getId().equals(id)) {
                return index;
            }
            else {
                return find(id, node.next, ++index);
            }
        }

        public void remove(int index) {
            if (index < 0 || index >= size) {
                throw new IndexOutOfBoundsException("Index out of bounds");
            }

            if (size == 1) {
                head = null;
                tail = null;
            } else if (index == 0) {
                head = head.next;
                head.prev = null;
            } else if (index == size - 1) {
                tail = tail.prev;
                tail.next = null;
            } else {
                Node currentNode = head;
                for (int i = 0; i < index; i++) {
                    currentNode = currentNode.next;
                }

                currentNode.prev.next = currentNode.next;
                currentNode.next.prev = currentNode.prev;
            }

            size--;
        }

        public int size() {
            return size;
        }

        public boolean isEmpty() {
            return size == 0;
        }

        public void printList() {
            Node currentNode = head;
            while (currentNode != null) {
                System.out.println(currentNode.data.getData().getId() + " ");
                currentNode = currentNode.next;
            }
            System.out.println();
        }
    }
}
