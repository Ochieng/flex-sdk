////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.layout
{
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.EventDispatcher;

import mx.components.baseClasses.GroupBase;
import mx.core.ScrollUnit;

import mx.containers.utilityClasses.Flex;
import mx.events.PropertyChangeEvent;
import mx.components.Group;


/**
 *  Documentation is not currently available.
 */
public class VerticalLayout extends LayoutBase
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    private static function calculatePercentWidth( layoutItem:ILayoutItem, width:Number ):Number
    {
    	var percentWidth:Number = LayoutItemHelper.pinBetween( layoutItem.percentWidth * 0.01 * width,
    	                                                       layoutItem.minSize.x,
    	                                                       layoutItem.maxSize.x );
    	return percentWidth < width ? percentWidth : width;
    }
        
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */    
    public function VerticalLayout():void
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  gap
    //----------------------------------
    
    private var _gap:int = 6;
    
    [Inspectable(category="General")]

    /**
     *  Vertical space between rows.
     * 
     *  @default 6
     */
    public function get gap():int
    {
        return _gap;
    }

    /**
     *  @private
     */
    public function set gap(value:int):void
    {
        if (_gap == value) 
            return;

        _gap = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  rowCount
    //----------------------------------

    private var _rowCount:int = -1;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  Returns the current number of visible items.
     * 
     *  @default -1
     */
    public function get rowCount():int
    {
        return _rowCount;
    }
    
    /**
     *  Sets the <code>rowCount</code> property and dispatches a
     *  PropertyChangeEvent.
     * 
     *  This method is intended to be used by subclass updateDisplayList() 
     *  methods to sync the rowCount property with the actual number
     *  of visible rows.
     *
     *  @param value The number of visible rows.
     */
    protected function setRowCount(value:int):void
    {
        if (_rowCount == value)
            return;
        var oldValue:int = _rowCount;
        _rowCount = value;
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "rowCount", oldValue, value));
    }
    
    //----------------------------------
    //  requestedRowCount
    //----------------------------------

    private var _requestedRowCount:int = -1;
    
    [Inspectable(category="General")]

    /**
     *  Specifies the number of items to display.
     * 
     *  If <code>requestedRowCount</code> is -1, then all of the items are displayed.
     * 
     *  This property implies the layout's <code>measuredHeight</code>.
     * 
     *  If the height of the <code>target</code> has been explicitly set,
     *  then this property has no effect.
     * 
     *  @default -1
     */
    public function get requestedRowCount():int
    {
        return _requestedRowCount;
    }

    /**
     *  @private
     */
    public function set requestedRowCount(value:int):void
    {
        if (_requestedRowCount == value)
            return;
                               
        _requestedRowCount = value;
        invalidateTargetSizeAndDisplayList();
    }    

    //----------------------------------
    //  rowHeight
    //----------------------------------
    
    private var _rowHeight:Number;

    [Inspectable(category="General")]

    /**
     *  Specifies the height of the rows if <code>variableRowHeight</code>
     *  is false.
     * 
     *  If this property isn't explicitly set, then the measured height
     *  of the first item is returned.
     */
    public function get rowHeight():Number
    {
        if (!isNaN(_rowHeight))
            return _rowHeight;
        else if (!target || (target.numLayoutItems <= 0))
            return 0;
        else
            return target.getLayoutItemAt(0).preferredSize.y;
    }

    /**
     *  @private
     */
    public function set rowHeight(value:Number):void
    {
        if (_rowHeight == value)
            return;
            
        _rowHeight = value;
        invalidateTargetSizeAndDisplayList();
    }
    
    //----------------------------------
    //  variableRowHeight
    //----------------------------------

    /**
     *  @private
     */
    private var _variableRowHeight:Boolean = true;

    [Inspectable(category="General")]

    /**
     *  If false, i.e. "fixed row height" is specified, the height of
     *  each item is set to the value of <code>rowHeight</code>.
     * 
     *  If the <code>rowHeight</code> property wasn't explicitly set,
     *  then it's initialized with the <code>measuredHeight</code> of
     *  the first item.
     * 
     *  The items' <code>includeInLayout</code>, 
     *  <code>measuredHeight</code>, <code>minHeight</code>,
     *  and <code>percentHeight</code> properties are ignored when 
     *  <code>variableRowHeight</code> is false.
     * 
     *  @default true
     */
    public function get variableRowHeight():Boolean
    {
        return _variableRowHeight;
    }

    /**
     *  @private
     */
    public function set variableRowHeight(value:Boolean):void
    {
        if (value == _variableRowHeight) 
            return;
        
        _variableRowHeight = value;
        invalidateTargetSizeAndDisplayList();
    }
    
    //----------------------------------
    //  firstIndexInView
    //----------------------------------

    /**
     *  @private
     */
    private var _firstIndexInView:int = -1;

    [Inspectable(category="General")]
    [Bindable("indexInViewChanged")]    

	/**
	 *  The index of the first row that's part of the layout and within
	 *  the layout target's scrollRect, or -1 if nothing has been displayed yet.
	 * 
	 *  Note that the row may only be partially in view.
	 * 
	 *  @see lastIndexInView
	 *  @see inView
	 */
	public function get firstIndexInView():int
	{
		return _firstIndexInView;
	}
	
	
    //----------------------------------
    //  lastIndexInView
    //----------------------------------

    /**
     *  @private
     */
    private var _lastIndexInView:int = -1;
    
    [Inspectable(category="General")]
    [Bindable("indexInViewChanged")]    

	/**
     *  The index of the last row that's part of the layout and within
     *  the layout target's scrollRect, or -1 if nothing has been displayed yet.
     * 
     *  Note that the row may only be partially in view.
     * 
     *  @see firstIndexInView
     *  @see inView
	 */
	public function get lastIndexInView():int
	{
		return _lastIndexInView;
	}

    /**
     *  Sets the <code>firstIndexInView</code> and <code>lastIndexInView</code>
     *  properties and dispatches a <code>"indexInViewChanged"</code>
     *  event.  
     * 
     *  This method is intended to be used by subclasses that 
     *  override updateDisplayList() to sync the first and 
     *  last indexInView properties with the current display.
     *
     *  @param firstIndex The new value for firstIndexInView.
     *  @param lastIndex The new value for lastIndexInView.
     * 
     *  @see firstIndexInView
     *  @see lastIndexInview
     */
    protected function setIndexInView(firstIndex:int, lastIndex:int):void
    {
        if ((_firstIndexInView == firstIndex) && (_lastIndexInView == lastIndex))
            return;
            
        _firstIndexInView = firstIndex;
        _lastIndexInView = lastIndex;
        dispatchEvent(new Event("indexInViewChanged"));
    }
    

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  An index is "in view" if the corresponding non-null layout item is 
	 *  within the vertical limits of the layout target's scrollRect
	 *  and included in the layout.
	 *  
	 *  Returns 1.0 if the specified index is completely in view, 0.0 if
	 *  it's not, and a value in between if the index is partially 
	 *  within the view.
	 * 
	 *  If the specified index is partially within the view, the 
	 *  returned value is the percentage of the corresponding layout
	 *  item that's visible.
	 * 
	 *  Returns 0.0 if the specified index is invalid or if it corresponds to
	 *  null item, or a ILayoutItem for which includeInLayout is false.
	 * 
	 *  @return the percentage of the specified item that's in view.
	 *  @see firstIndexInView
	 *  @see lastIndexInView
	 */
	public function inView(index:int):Number 
	{
		var g:GroupBase = GroupBase(target);
	    if (!g)
	        return 0.0;
	        
	    if ((index < 0) || (index >= g.numLayoutItems))
	       return 0.0;
	       
        var li:ILayoutItem = g.getLayoutItemAt(index);
        if ((li == null) || !li.includeInLayout)
            return 0.0;
            
        if (!clipContent)
            return 1.0;

        var r0:int = firstIndexInView;	
        var r1:int = lastIndexInView;
        
        // outside the visible index range
        if ((r0 == -1) || (r1 == -1) || (index < r0) || (index > r1))
            return 0.0;
            
        // within the visible index range, but not first or last            
        if ((index > r0) && (index < r1))
            return 1.0;

        // index is first (r0) or last (r1) visible row
        var y0:Number = g.verticalScrollPosition;
        var y1:Number = y0 + g.height;
        var iy0:Number = li.actualPosition.y;
        var iy1:Number = iy0 + li.actualSize.y;
        if (iy0 >= iy1)  // item has 0 or negative height
            return 1.0;
        if ((iy0 >= y0) && (iy1 <= y1))
            return 1.0;
        return (Math.min(y1, iy1) - Math.max(y0, iy0)) / (iy1 - iy0);
	}
	
	/**
	 *  Binary search for the first layout item that contains y.  
	 * 
	 *  This function considers both the item's actual bounds and 
	 *  the gap that follows it to be part of the item.  The search 
	 *  covers index i0 through i1 (inclusive).
	 *  
	 *  This function is intended for variable height items.
	 * 
	 *  Returns the index of the item that contains y, or -1.
	 *   
	 * @private 
	 */
	private static function findIndexAt(y:Number, gap:int, g:GroupBase, i0:int, i1:int):int
	{
	    var index:int = (i0 + i1) / 2;
        var item:ILayoutItem = g.getLayoutItemAt(index);	    
	    var p:Point = item.actualPosition;
        var s:Point = item.actualSize;
        // TBD: deal with null item, includeInLayout false.
        if ((y >= p.y) && (y < p.y + s.y + gap))
            return index;
        else if (i0 == i1)
            return -1;
        else if (y < p.y)
            return findIndexAt(y, gap, g, i0, Math.max(i0, index-1));
        else 
            return findIndexAt(y, gap, g, Math.min(index+1, i1), i1);
	} 
	
   /**
    *  Returns the index of the first non-null includeInLayout item, 
    *  beginning with the item at index i.  
    * 
    *  Returns -1 if no such item can be found.
    *  
    *  @private
    */
    private static function findLayoutItemIndex(g:GroupBase, i:int, dir:int):int
    {
        var n:int = g.numLayoutItems;
        while((i >= 0) && (i < n))
        {
           var item:ILayoutItem = g.getLayoutItemAt(i);
           if (item && item.includeInLayout)
           {
               return i;      
           }
           i += dir;
        }
        return -1;
    }

   /**
    *  Updates the first,lastIndexInView properties per the new
    *  scroll position.
    *  
    *  @see setIndexInView
    */
    override protected function scrollPositionChanged():void
    {
        super.scrollPositionChanged();
        
        var g:GroupBase = target;
        if (!g)
            return;     

        var n:int = g.numLayoutItems - 1;
        if (n < 0) 
        {
            setIndexInView(-1, -1);
            return;
        }
        
        var scrollR:Rectangle = g.scrollRect;
        if (!scrollR)
        {
            setIndexInView(0, n);
            return;    
        }
        
        // We're going to use findIndexAt to find the index of 
        // the items that overlap the top and bottom edges of the scrollRect.
        // Values that are exactly equal to scrollRect.bottom aren't actually
        // rendered, since the top,bottom interval is only half open.
        // To account for that we back away from the bottom edge by a
        // hopefully infinitesimal amount.
        
        var y0:Number = scrollR.top;
        var y1:Number = scrollR.bottom - .0001;
        if (y1 <= y0)
        {
            setIndexInView(-1, -1);
            return;
        }

        // TBD: special case for variableRowHeight false

        var i0:int = findIndexAt(y0 + gap, gap, g, 0, n);
        var i1:int = findIndexAt(y1, gap, g, 0, n);

        // Special case: no item overlaps y0, is index 0 visible?
        if (i0 == -1)
        {   
            var index0:int = findLayoutItemIndex(g, 0, +1);
            if (index0 != -1)
            {
                var item0:ILayoutItem = g.getLayoutItemAt(index0); 
                var p0:Point = item0.actualPosition;
                var s0:Point = item0.actualSize;                 
                if ((p0.y < y1) && ((p0.y + s0.y) > y0))
                    i0 = index0;
            }
        }

        // Special case: no item overlaps y1, is index n visible?
        if (i1 == -1)
        {
            var index1:int = findLayoutItemIndex(g, n, -1);
            if (index1 != -1)
            {
                var item1:ILayoutItem = g.getLayoutItemAt(index1); 
                var p1:Point = item1.actualPosition;
                var s1:Point = item1.actualSize;                 
                if ((p1.y < y1) && ((p1.y + s1.y) > y0))
                    i1 = index1;
            }
        }   

        setIndexInView(i0, i1);
    }

    /**
     *  If the item at index i is non-null and includeInLayout,
     *  then return it's actual bounds, otherwise return null.
     * 
     *  @private
     */
    private static function layoutItemBounds(g:GroupBase, i:int):Rectangle
    {
        var item:ILayoutItem = g.getLayoutItemAt(i);
        if (item && item.includeInLayout)
        {
            var p:Point = item.actualPosition;
            var s:Point = item.actualSize; 
            return new Rectangle(p.x, p.y, s.x, s.y);        
        }
        return null;    
    }
    
    /**
     *  Returns the actual position/size Rectangle of the first partially 
     *  visible or not-visible, non-null includeInLayout item, beginning
     *  with the item at index i, searching in direction dir (dir must
     *  be +1 or -1).   The last argument is the GroupBase scrollRect, it's
     *  guaranteed to be non-null.
     * 
     *  Returns null if no such item can be found.
     *  
     *  @private
     */
    private function findLayoutItemBounds(g:GroupBase, i:int, dir:int, r:Rectangle):Rectangle
    {
        var n:int = g.numLayoutItems;

        if (inView(i) >= 1)
            i = Math.max(0, Math.min(n - 1, i + dir));

        while((i >= 0) && (i < n))
        {
           var itemR:Rectangle = layoutItemBounds(g, i);
           // Special case: if the scrollRect r _only_ contains
           // itemR, then if we're searching up (dir == -1),
           // and itemR's top edge is visible, then try again
           // with i-1.   Likewise for dir == +1.
           if (itemR)
           {
               var overlapsTop:Boolean = (dir == -1) && (itemR.top == r.top) && (itemR.bottom >= r.bottom);
               var overlapsBottom:Boolean = (dir == +1) && (itemR.bottom == r.bottom) && (itemR.top <= r.top);
               if (!(overlapsTop || overlapsBottom))             
                   return itemR;
           }
           i += dir;
        }
        return null;
    }

    /**
     *  Overrides the default handling of UP/DOWN and 
     *  PAGE_UP, PAGE_DOWN. 
     * 
     *  <ul>
     * 
     *  <li> 
     *  <code>UP</code>
     *  If the firstIndexInView item is partially visible then top justify
     *  it, otherwise top justify the item at the previous index.
     *  </li>
     * 
     *  <li> 
     *  <code>DOWN</code>
     *  If the lastIndexInView item is partially visible, then bottom justify
     *  it, otherwise bottom justify the item at the following index.
     *  </li>
     * 
     *  <code>PAGE_UP</code>
     *  <li>
     *  If the firstIndexInView item is partially visible, then bottom
     *  justify it, otherwise bottom justify item at the previous index.  
     *  </li>
     * 
     *  <li> 
     *  <code>PAGE_DOWN</code>
     *  If the lastIndexInView item is partially visible, then top
     *  justify it, otherwise top justify item at the following index.  
     *  </li>
     *  
     *  </ul>
     *   
     *  @see firstIndexInView
     *  @see lastIndexInView
     *  @see verticalScrollPosition
     */
    override public function getVerticalScrollPositionDelta(unit:ScrollUnit):Number
    {
        var g:GroupBase = target;
        if (!g)
            return 0;     

        var maxIndex:int = g.numLayoutItems -1;
        if (maxIndex < 0)
            return 0;
            
        var scrollR:Rectangle = g.scrollRect;
        if (!scrollR)
            return 0;
            
        var itemR:Rectangle = null;
        switch(unit)
        {
            case ScrollUnit.UP:
            case ScrollUnit.PAGE_UP:
                itemR = findLayoutItemBounds(g, firstIndexInView, -1, scrollR);
                break;

            case ScrollUnit.DOWN:
            case ScrollUnit.PAGE_DOWN:
                itemR = findLayoutItemBounds(g, lastIndexInView, +1, scrollR);
                break;

            default:
                return super.getVerticalScrollPositionDelta(unit);
        }
        
        if (!itemR)
            return 0;
            
        var delta:Number = 0;            
        switch (unit)
        {
            case ScrollUnit.UP:
                delta = Math.max(-scrollR.height, itemR.top - scrollR.top);
                break;
                
            case ScrollUnit.DOWN:
                delta = Math.min(scrollR.height, itemR.bottom - scrollR.bottom);
                break;
                
            case ScrollUnit.PAGE_UP:
                if ((itemR.top < scrollR.top) && (itemR.bottom >= scrollR.bottom))
                    delta = Math.max(-scrollR.height, itemR.top - scrollR.top);
                else
                    delta = itemR.bottom - scrollR.bottom;
                break;

            case ScrollUnit.PAGE_DOWN:
                if ((itemR.top <= scrollR.top) && (itemR.bottom > scrollR.bottom))
                    delta = Math.min(scrollR.height, itemR.bottom - scrollR.bottom);
                else
                    delta = itemR.top - scrollR.top;
                break;
        }

        var maxDelta:Number = g.contentHeight - scrollR.height - scrollR.y;
        var minDelta:Number = -scrollR.y;
        return Math.min(maxDelta, Math.max(minDelta, delta));
    }     
        
    private function variableRowHeightMeasure(layoutTarget:GroupBase):void
    {
        var minWidth:Number = 0;
        var minHeight:Number = 0;
        var preferredWidth:Number = 0;
        var preferredHeight:Number = 0;
        var visibleHeight:Number = 0;
        var visibleRows:uint = 0;
        var reqRows:int = requestedRowCount;
         
        var count:uint = layoutTarget.numLayoutItems;
        var totalCount:uint = count; // How many items will be laid out
        for (var i:int = 0; i < count; i++)
        {
            var li:ILayoutItem = layoutTarget.getLayoutItemAt(i);
            if (!li || !li.includeInLayout)
            {
            	totalCount--;
                continue;
            }            

            preferredWidth = Math.max(preferredWidth, li.preferredSize.x);
            preferredHeight += li.preferredSize.y; 
            
            var vrr:Boolean = (reqRows != -1) && (visibleRows < reqRows);

            if (vrr || (reqRows == -1))
            {
                var mw:Number =  hasPercentWidth(li) ? li.minSize.x : li.preferredSize.x;
                var mh:Number = hasPercentHeight(li) ? li.minSize.y : li.preferredSize.y;                   
                minWidth = Math.max(mw, minWidth);
                minHeight += mh;
            }

            if (vrr) 
            {
                visibleHeight = preferredHeight;
                visibleRows += 1;
            }            
        }
        
        if (totalCount > 1)
        { 
            preferredHeight += gap * (totalCount - 1);
            var vgap:Number = (visibleRows > 1) ? (gap * (visibleRows - 1)) : 0;
            visibleHeight += vgap;
            minHeight += vgap;
        }
        
        layoutTarget.measuredWidth = preferredWidth;
        layoutTarget.measuredHeight = (reqRows == -1) ? preferredHeight : visibleHeight;

        layoutTarget.measuredMinWidth = minWidth; 
        layoutTarget.measuredMinHeight = minHeight;

        layoutTarget.setContentSize(preferredWidth, preferredHeight);
    }
   
   
    private function fixedRowHeightMeasure(layoutTarget:GroupBase):void
    {
    	var rows:uint = layoutTarget.numLayoutItems;
        var visibleRows:uint = (requestedRowCount == -1) ? rows : requestedRowCount;
        
        var rh:Number = rowHeight; // can be expensive to compute
        var contentHeight:Number = (rows * rh) + ((rows > 1) ? (gap * (rows - 1)) : 0);
        var visibleHeight:Number = (visibleRows * rh) + ((visibleRows > 1) ? (gap * (visibleRows - 1)) : 0);
        
        var columnWidth:Number = layoutTarget.explicitWidth;
        var minColumnWidth:Number = columnWidth;
        if (isNaN(columnWidth)) 
        {
			minColumnWidth = columnWidth = 0;
	        var count:uint = layoutTarget.numLayoutItems;
	        for (var i:int = 0; i < count; i++)
	        {
	            var layoutItem:ILayoutItem = layoutTarget.getLayoutItemAt(i);
	            if (!layoutItem || !layoutItem.includeInLayout) 
	               continue;
	            columnWidth = Math.max(columnWidth, layoutItem.preferredSize.x);
	            var itemMinWidth:Number = hasPercentWidth(layoutItem) ? layoutItem.minSize.x : layoutItem.preferredSize.x;
	            minColumnWidth = Math.max(minColumnWidth, itemMinWidth);
	        }
        }     
        
        layoutTarget.measuredWidth = columnWidth;
        layoutTarget.measuredHeight = visibleHeight;

        layoutTarget.measuredMinWidth = minColumnWidth;
        layoutTarget.measuredMinHeight = visibleHeight;
        
        layoutTarget.setContentSize(columnWidth, contentHeight);
    }
    
    
    override public function measure():void
    {
    	var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        if (variableRowHeight) 
            variableRowHeightMeasure(layoutTarget);
        else 
            fixedRowHeightMeasure(layoutTarget);

    }
    
    
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
    	var layoutTarget:GroupBase = target; 
        if (!layoutTarget)
            return;
        
        // TODO EGeorgie: use vector
        var layoutItemArray:Array = new Array();
        var layoutItem:ILayoutItem;
        var count:uint = layoutTarget.numLayoutItems;
        var totalCount:uint = count; // How many items will be laid out
        for (var i:int = 0; i < count; i++)
        {
            layoutItem = layoutTarget.getLayoutItemAt(i);
            if (!layoutItem || !layoutItem.includeInLayout)
            {
            	totalCount--;
                continue;
            } 
            layoutItemArray.push(layoutItem);
        }

        var totalHeightToDistribute:Number = unscaledHeight;
        if (totalCount > 1)
            totalHeightToDistribute -= (totalCount - 1) * gap;

        distributeHeight(layoutItemArray, unscaledWidth, totalHeightToDistribute); 
                            
        // TODO EGeorgie: horizontalAlign
        var hAlign:Number = 0;
        
        // As the LayoutItems are positioned, we'll count how many rows 
        // fall within the layoutTarget's scrollRect
        var visibleRows:uint = 0;
        var minVisibleY:Number = layoutTarget.verticalScrollPosition;
        var maxVisibleY:Number = minVisibleY + unscaledHeight;
        
        // Finally, position the LayoutItems and find the first/last
        // visible indices, the content size, and the number of 
        // visible items.    
        var y:Number = 0;
        var maxX:Number = 0;
        var maxY:Number = 0;
        var firstRowInView:int = -1;
        var lastRowInView:int = -1;

        // rowHeight can be expensive to compute
        var rh:Number = (variableRowHeight) ? 0 : rowHeight;
        
        for (var index:int = 0; index < count; index++)
        {
            layoutItem = layoutTarget.getLayoutItemAt(index);
            if (!layoutItem || !layoutItem.includeInLayout)
                continue;

        	// Set the layout item's acutual size and position
            var x:Number = (unscaledWidth - layoutItem.actualSize.x) * hAlign;
            layoutItem.setActualPosition(x, y);
            var dx:Number = layoutItem.actualSize.x;
            if (!variableRowHeight)
                layoutItem.setActualSize(dx, rh);
                
            // Update maxX,Y, first,lastVisibleIndex, and y
            var dy:Number = layoutItem.actualSize.y;
            maxX = Math.max(maxX, x + dx);
            maxY = Math.max(maxY, y + dy);
            if (!clipContent ||
                ((y < maxVisibleY) && ((y + dy) > minVisibleY)) || 
                ((dy <= 0) && ((y == maxVisibleY) || (y == minVisibleY))))
            {
            	visibleRows += 1;
            	if (firstRowInView == -1)
            	   firstRowInView = lastRowInView = index;
            	else
            	   lastRowInView = index;
            }
            y += dy + gap;
        }
        
        setRowCount(visibleRows);
        setIndexInView(firstRowInView, lastRowInView);
        layoutTarget.setContentSize(maxX, maxY);
    }
    
    /**
     *  This function sets the height of each child
     *  so that the heights add up to <code>height</code>. 
     *  Each child is set to its preferred height
     *  if its percentHeight is zero.
     *  If its percentHeight is a positive number,
     *  the child grows (or shrinks) to consume its
     *  share of extra space.
     *  
     *  The return value is any extra space that's left over
     *  after growing all children to their maxHeight.
     */
    public function distributeHeight(layoutItemArray:Array,
                                     width:Number,
                                     height:Number):Number
    {
        var spaceToDistribute:Number = height;
        var totalPercentHeight:Number = 0;
        var childInfoArray:Array = [];
        var childInfo:LayoutItemFlexChildInfo;
        var newWidth:Number;
        
        // If the child is flexible, store information about it in the
        // childInfoArray. For non-flexible children, just set the child's
        // width and height immediately.
        for each (var layoutItem:ILayoutItem in layoutItemArray)
        {
            if (hasPercentHeight(layoutItem))
            {
                totalPercentHeight += layoutItem.percentHeight;

                childInfo = new LayoutItemFlexChildInfo();
                childInfo.layoutItem = layoutItem;
                childInfo.percent    = layoutItem.percentHeight;
                childInfo.min        = layoutItem.minSize.y;
                childInfo.max        = layoutItem.maxSize.y;
                
                childInfoArray.push(childInfo);                
            }
            else
            {
                newWidth = NaN;
                if (hasPercentWidth(layoutItem))
                   newWidth = calculatePercentWidth(layoutItem, width);
                
                layoutItem.setActualSize(newWidth, NaN);
                spaceToDistribute -= layoutItem.actualSize.y;
            } 
        }

        // Distribute the extra space among the flexible children
        if (totalPercentHeight)
        {
            spaceToDistribute = Flex.flexChildrenProportionally(height,
                                                                spaceToDistribute,
                                                                totalPercentHeight,
                                                                childInfoArray);
            for each (childInfo in childInfoArray)
            {
            	newWidth = NaN;
            	if (hasPercentWidth(childInfo.layoutItem))
            	   newWidth = calculatePercentWidth(childInfo.layoutItem, width);

                childInfo.layoutItem.setActualSize(newWidth, childInfo.size);
            }
        }
        return spaceToDistribute;
    }
}
}

[ExcludeClass]

import mx.layout.ILayoutItem;
import mx.containers.utilityClasses.FlexChildInfo;

class LayoutItemFlexChildInfo extends FlexChildInfo
{
    public var layoutItem:ILayoutItem;	
}
