//
// Accordion.swift
// Ignite
// https://www.github.com/twostraws/Ignite
// See LICENSE for license information.
//

/// A control that displays a list of section titles that can be folded out to
/// display more content.
public struct Accordion: HTML {
    /// Controls what happens when a section is opened.
    public enum OpenMode: Sendable {
        /// Opening one accordion section automatically closes all others.
        case individual

        /// Users can open multiple sections simultaneously.
        case all
    }

    /// The visual style of the accordion.
    public enum Style: Sendable {
        /// A style with outer borders and rounded corners.
        case bordered

        /// Removes outer borders and rounded corners.
        case plain

        /// The default styling based on context.
        public static var automatic: Self { .bordered }
    }

    /// The content and behavior of this HTML.
    public var body: some HTML { self }

    /// The standard set of control attributes for HTML elements.
    public var attributes = CoreAttributes()

    /// Whether this HTML belongs to the framework.
    public var isPrimitive: Bool { true }

    /// A collection of sections you want to show inside this accordion.
    private var items: [Item]

    /// Adjusts what happens when a section is opened.
    /// Defaults to `.individual`, meaning that only one
    /// accordion section may be open at a time.
    private var openMode = OpenMode.individual

    /// Create a new Accordion from a collection of sections.
    /// - Parameter items: A result builder containing all the sections
    /// you want to display in this accordion.
    public init(@ElementBuilder<Item> _ items: () -> [Item]) {
        self.items = items()
    }

    /// Creates a new `Accordion` instance from a collection of items, along with a function
    /// that converts a single object from the collection into one item in the accordion.
    /// - Parameters:
    ///   - items: A sequence of items you want to convert into items.
    ///   - content: A function that accepts a single value from the sequence, and
    ///     returns a row representing that value in the accordion.
    public init<T>(_ items: any Sequence<T>, content: (T) -> Item) {
        self.items = items.map(content)
    }

    /// Adjusts the open mode for this Accordion.
    /// - Parameter mode: The new open mode.
    /// - Returns: A copy of this Accordion with the new open mode set.
    public func openMode(_ mode: OpenMode) -> Self {
        var copy = self
        copy.openMode = mode
        return copy
    }

    /// Sets the visual style of the accordion.
    /// - Parameter style: The style to apply to the accordion.
    /// - Returns: A modified copy of this accordion with the new style applied.
    public func accordionStyle(_ style: Style) -> Self {
        var copy = self
        copy.attributes.append(classes: "accordion-flush")
        return copy
    }

    /// Sets different background colors for normal and active states of accordion headers.
    /// - Parameters:
    ///   - closed: The color to use for normal (inactive) headers.
    ///   - open: The color to use for active (selected) headers.
    /// - Returns: A modified copy of this accordion with the new header backgrounds.
    public func headerBackground(_ closed: Color, open: Color) -> Self {
        var copy = self
        copy.attributes.append(styles: .init("--bs-accordion-btn-bg", value: closed.description))
        copy.attributes.append(styles: .init("--bs-btn-hover-bg", value: closed.description))
        copy.attributes.append(styles: .init("--bs-btn-active-bg", value: closed.description))
        copy.attributes.append(styles: .init("--bs-accordion-active-bg", value: open.description))
        return copy
    }

    /// Sets the same background color for both normal and active states of accordion headers.
    /// - Parameter color: The color to use for all header states.
    /// - Returns: A modified copy of this accordion with the new header background.
    public func headerBackground(_ color: Color) -> Self {
        self.headerBackground(color, open: color)
    }

    /// Sets different text colors for normal and active states of accordion headers.
    /// - Parameters:
    ///   - closed: The text color to use for normal (inactive) headers.
    ///   - open: The text color to use for active (selected) headers.
    /// - Returns: A modified copy of this accordion with the new header text colors.
    public func headerForegroundStyle(_ closed: Color, open: Color) -> Self {
        var copy = self
        copy.attributes.append(styles: .init("--bs-accordion-btn-color", value: closed.description))
        copy.attributes.append(styles: .init("--bs-btn-hover-color", value: closed.description))
        copy.attributes.append(styles: .init("--bs-btn-active-color", value: closed.description))
        copy.attributes.append(styles: .init("--bs-accordion-active-color", value: open.description))
        return copy
    }

    /// Sets the same text color for both normal and active states of accordion headers.
    /// - Parameter color: The text color to use for all header states.
    /// - Returns: A modified copy of this accordion with the new header text color.
    public func headerForegroundStyle(_ color: Color) -> Self {
        self.headerForegroundStyle(color, open: color)
    }

    /// Sets the border color for the accordion.
    /// - Parameter color: The color to use for accordion borders.
    /// - Returns: A modified copy of this accordion with the new border color.
    public func borderColor(_ color: Color) -> Self {
        var copy = self
        copy.attributes.append(styles: .init("--bs-accordion-border-color", value: color.description))
        return copy
    }

    /// Renders this element using publishing context passed in.
    /// - Returns: The HTML for this element.
    public func markup() -> Markup {
        // Accordions with an individual open mode must have
        // each element linked back to a unique accordion ID.
        // This is generated below, then passed into individual
        // items so they can adapt accordinly.
        let accordionID = "accordion\(UUID().uuidString.truncatedHash)"
        let content = Section {
            ForEach(items) { item in
                item.assigned(to: accordionID, openMode: openMode)
            }
        }
        .attributes(attributes)
        .class("accordion")
        .id(accordionID)

        return content.markup()
    }
}
