<!--
{
  "title": "Kernel Memory Management",
  "date": "2017-05-04T20:13:46+09:00",
  "category": "",
  "tags": ["linux", "mm"],
  "draft": true
}
-->


# TODO

- Follow each part of memory management hierarchy:
  - page frame management (buddy system): `alloc_pages`
  - slab allocator: `kmalloc`
    - doesn't change kernel page table ?
  - not-physically-contiguous allocator: `vmalloc`
    - does change kernel page table ?

- Process's point of view
  - page fault
  - clone and COW ?

Q.
- where is mem_map (global array for struct page) defined for x86_64 ?


# Linux source

```
- include/linux/
  - mm.h
    - void *page_address(struct page *)
  - mm_types.h
    - struct page
    - struct vm_region, struct vm_area_struct
    - struct mm_struct
  - gfp.h

- include/asm-generic/
  - memory_model.h
    - pfn_to_page, page_to_pfn, __pfn_to_phys, __phys_to_pfn

- mm/
  - page_alloc.c
    - struct page *alloc_pages(gfp_t, unsigned int order)
  - memory.c
    - ?

- arch/x86/include/asm/
  - page.h
    - __pa, __va
    - pfn_to_page, ...
  - page_64_types.h
    - __PAGE_OFFSET_BASE (0xffff880000000000)
    - __START_KERNEL_map (0xffffffff80000000)
    - (some constants mentioned in Documentation/x86/x86_64/mm.txt)
  - page_types.h
    - PAGE_OFFSET
    - PAGE_SHIFT, PAGE_SIZE
  - pgtable_64_types.h
    - PMD_SHIFT, PMD_SIZE, ...
    - typedef pte_t
  - pgtable_types.h
    - FIRST_USER_ADDRESS
    - _PAGE_BIT_XXX (e.g. _PAGE_BIT_PRESENT)
```


# Initialization


# Page allocation (i.e. page table update)
