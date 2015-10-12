//
//  ViewController.swift
//  VKSlider
//
//  Created by Viacheslav Karamov on 29.09.15.
//  Copyright © 2015 Viacheslav Karamov. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{

    @IBOutlet weak var selectedIndexLabel: UILabel!
    @IBOutlet weak var slider:VKSlider!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        slider.cornerRadius = 3.0;
        slider.titles = ["First", "Second", "One more long thing"]
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeSelectedIndex(sender: VKSlider)
    {
        selectedIndexLabel.text = "Selected Index: \(sender.getSelectedIndex())"
    }


}

