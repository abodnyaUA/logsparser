//
//  ViewController.swift
//  LogsParser
//
//  Created by Aleksey Bodnya on 8/18/17.
//  Copyright © 2017 Aleksey Bodnya. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSSearchFieldDelegate {

    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var secondSearchField: NSSearchField!
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet weak var tableView: NSTableView!

    var displayOnlyMarked = false {
        didSet {
            self.predicateFilter = self.displayOnlyMarked ? NSPredicate(format: "SELF in %@", self.marked) : NSPredicate(format: "TRUEPREDICATE")
        }
    }

    var marked = [Message]()
    var lines = NSMutableDictionary()

    var predicate1 = NSPredicate(format: "TRUEPREDICATE") {
        didSet {
            self.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.predicate1, self.predicate2, self.predicateFilter])
        }
    }

    var predicate2 = NSPredicate(format: "TRUEPREDICATE") {
        didSet {
            self.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.predicate1, self.predicate2, self.predicateFilter])
        }
    }

    var predicateFilter = NSPredicate(format: "TRUEPREDICATE") {
        didSet {
            self.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [self.predicate1, self.predicate2, self.predicateFilter])
        }
    }

    var predicate = NSPredicate(format: "TRUEPREDICATE") {
        didSet {
            self.arrayController.filterPredicate = predicate
        }
    }

    var document: Document? {
        return self.representedObject as? Document
    }

    override var representedObject: Any? {
        didSet {
            self.arrayController.add(contentsOf: self.document!.messages)
            self.tableView.deselectAll(self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchField.delegate = self
        self.secondSearchField.delegate = self
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        AppDelegate.shared.displayOnlyMarkedMenuItem.state = self.displayOnlyMarked ? NSOnState : NSOffState
    }

    func message(at index: Int) -> Message {
        let array = self.arrayController.arrangedObjects as! NSArray
        let message = array[index] as! Message
        return message
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let message = self.message(at: row)
        return 17.0 * CGFloat(message.linesCount)
    }

    func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
        if tableColumn?.identifier == "message" {
            let message = self.message(at: row)
            let textCell = cell as! NSTextFieldCell
            let string = NSMutableAttributedString()
            if message.level == .error {
                string.append(NSAttributedString(string: message.message, attributes: [NSForegroundColorAttributeName: NSColor.red]))
            } else if message.message == "==========================================" {
                string.append(NSAttributedString(string: message.message, attributes: [
                    NSForegroundColorAttributeName: NSColor.blue,
                    NSBackgroundColorAttributeName: NSColor.lightGray,
                    NSFontAttributeName: NSFont.boldSystemFont(ofSize: 17.0)
                ]))
            } else {
                string.append(NSAttributedString(string: message.message))
            }
            textCell.attributedStringValue = string
        } else if tableColumn?.identifier == "flag" {
            let message = self.message(at: row)
            let imageCell = cell as! NSImageCell
            if self.marked.contains(message) {
                imageCell.image = NSImage(named: "flag")
            } else {
                imageCell.image = nil
            }
        }
    }

    override func controlTextDidChange(_ obj: Notification) {
        let sender = obj.object as! NSSearchField
        if sender == self.searchField {
            self.predicate1 = sender.stringValue.characters.count > 0 ? NSPredicate(format: "message contains[cd] %@ OR method contains[cd] %@", sender.stringValue, sender.stringValue) : NSPredicate(format: "TRUEPREDICATE")
        } else if sender == self.secondSearchField {
            self.predicate2 = sender.stringValue.characters.count > 0 ? NSPredicate(format: "message contains[cd] %@ OR method contains[cd] %@", sender.stringValue, sender.stringValue) : NSPredicate(format: "TRUEPREDICATE")
        }
    }

    @IBAction func displayOnlyMarkedTapped(_ sender: Any) {
        self.displayOnlyMarked = !(self.displayOnlyMarked)
        AppDelegate.shared.displayOnlyMarkedMenuItem.state = self.displayOnlyMarked ? NSOnState : NSOffState
    }

    @IBAction func markSelected(_ sender: Any) {
        let row = self.tableView.selectedRow
        if row >= 0 {
            let message = self.message(at: row)
            if self.marked.contains(message) {
                self.marked.remove(at: self.marked.index(of: message)!)
            } else {
                self.marked.append(message)
            }
            self.tableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(integer: 0))
        }
    }
}
