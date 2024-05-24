<template>
    <div class="h-screen flex items-center justify-center">
        <h1 class="text-4xl font-bold">{{ resourceName }}</h1>
    </div>
</template>

<script lang="ts" setup>
const resourceName = (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : 'nui-frame-app'
</script>
