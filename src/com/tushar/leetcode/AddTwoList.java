package com.tushar.leetcode;

/*
You are given two non-empty linked lists representing two non-negative integers.
The digits are stored in reverse order, and each of their nodes contains a single digit.
Add the two numbers and return the sum as a linked list.
You may assume the two numbers do not contain any leading zero, except the number 0 itself.

Example 1:
Input: l1 = [2,4,3], l2 = [5,6,4]
Output: [7,0,8]
Explanation: 342 + 465 = 807.
Example 2:

Input: l1 = [0], l2 = [0]
Output: [0]
Example 3:

Input: l1 = [9,9,9,9,9,9,9], l2 = [9,9,9,9]
Output: [8,9,9,9,0,0,0,1]
 */
public class AddTwoList {
    public static void main(String[] args) {
        int[] arrl1 = {9,9,9,9,9,9,9};
        int[] arrl2 = {9,9,9,9};
        ListNode l1 = new ListNode();
        ListNode t = l1;

        for (int i = 0; i < arrl1.length; ++ i) {
            t.val = arrl1[i];
            if (i < arrl1.length - 1) {
                t.next = new ListNode();
                t = t.next;
            }
        }

        ListNode l2 = new ListNode();
        t = l2;
        for (int i = 0; i < arrl2.length; ++ i) {
            t.val = arrl2[i];
            if (i < arrl2.length - 1) {
                t.next = new ListNode();
                t = t.next;
            }
        }

        ListNode res = addTwoNumbers(l1, l2);

        while (res != null) {
            System.out.println(res.val);
            res = res.next;
        }

    }
    public static ListNode addTwoNumbers(ListNode l1, ListNode l2) {
        ListNode result = new ListNode();
        ListNode dataL1 = l1;
        ListNode dataL2 = l2;
        int sum = 0;
        ListNode t = result;
        boolean flag = false;
        while (dataL1 != null || dataL2 != null) {
            if (flag) {
                t.next = new ListNode();
                t = t.next;
            }
            if (dataL1 != null) {
                sum += dataL1.val;
                dataL1 = dataL1.next;
            }
            if (dataL2 != null) {
                sum += dataL2.val;
                dataL2 = dataL2.next;
            }
            t.val = sum % 10;
            sum = sum / 10;
            System.out.println("Sum " + sum);
            flag = true;
        }
        if (sum == 0) {
            t = null;
        } else {
            t.next = new ListNode();
            t = t.next;
            t.val = sum;
            t.next = null;
        }
        return result;
    }
}

class ListNode {
    int val;
    ListNode next;
    ListNode() {}
    ListNode(int val) { this.val = val; }
    ListNode(int val, ListNode next) { this.val = val; this.next = next; }
}

