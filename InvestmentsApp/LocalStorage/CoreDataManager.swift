//
//  CoreDataManager.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import Foundation
import CoreData

class CoreDataManager: LocalStorageManager {
    private let container: NSPersistentContainer
    private let containerName: String = "MarketOperationsContainer"
    private let marketOperationsEntity: String = "MarketOperationsEntity"
    
    private var savedMarketOperations: [MarketOperationsEntity] = []
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Error loading Core Data. \(error.localizedDescription)")
            }
            self.getMarketOperationsFromStorage()
        }
    }
    
    private func getMarketOperationsFromStorage() {
        let request = NSFetchRequest<MarketOperationsEntity>(entityName: marketOperationsEntity)
        
        let sortByDate = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortByDate]
        
        do {
            savedMarketOperations = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching market operations entity. \(error.localizedDescription)")
        }
    }

    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving to Core Data. \(error.localizedDescription)")
        }
    }
    
    func save(operation: MarketOperation) {
        if let entity = savedMarketOperations.first(where: { $0.id == operation.id }) {
            update(entity: entity, with: operation)
        } else {
            add(operation: operation)
        }
    }
    
    private func add(operation: MarketOperation) {
        let entity = MarketOperationsEntity(context: container.viewContext)
        
        fillRequisites(in: entity, from: operation)
        
        save()
        getMarketOperationsFromStorage()
    }
    
    private func update(entity: MarketOperationsEntity, with operation: MarketOperation) {
        fillRequisites(in: entity, from: operation)
        save()
    }
    
    private func fillRequisites(in entity: MarketOperationsEntity, from operation: MarketOperation) {
        entity.id = operation.id
        entity.date = operation.date
        entity.price = operation.price
        entity.quantity = operation.quantity
        entity.ticket = operation.ticket
        entity.type = operation.type.rawValue
    }
    
    func delete(operation: MarketOperation) {
        if let entity = savedMarketOperations.first(where: { $0.id == operation.id }) {
            delete(entity: entity)
        }
    }
    
    private func delete(entity: MarketOperationsEntity) {
        container.viewContext.delete(entity)
        save()
        savedMarketOperations.removeAll(where: { $0.id == entity.id })
    }
    
    func getOperations(from dateStart: Date, to dateEnd: Date) -> [MarketOperation] {
        return getOperations().filter({ dateStart <= $0.date && $0.date <= dateEnd })
    }
    
    func getOperations() -> [MarketOperation] {
        var result = [MarketOperation]()
        
        for entity in savedMarketOperations {
            let operation = MarketOperation(id: entity.id ?? "",
                                            type: MarketOperation.OperationType(rawValue: entity.type ?? "") ?? .buy,
                                            date: entity.date ?? Date(),
                                            ticket: entity.ticket ?? "",
                                            quantity: entity.quantity,
                                            price: entity.price)
            
            result.append(operation)
        }
        
        return result
    }
}
